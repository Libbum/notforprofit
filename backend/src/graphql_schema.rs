extern crate dotenv;

use std::env;

use diesel::pg::PgConnection;
use diesel::prelude::*;
use dotenv::dotenv;
use juniper::RootNode;
use url::Url;

use crate::schema::publishers;

#[derive(Queryable)]
pub struct Publisher {
    #[allow(unused)]
    id: i32,
    name: String,
}

#[juniper::object(description = "A Journal Publication House")]
impl Publisher {
    pub fn name(&self) -> &str {
        self.name.as_str()
    }
}

#[derive(Queryable)]
pub struct Journal {
    #[allow(unused)]
    id: i32,
    name: String,
    url: Option<String>,
    publisher_id: i32,
    for_profit: bool,
    open_access_fee: Option<i32>, //TODO: Need to check what graphql needs for conversions here.
    open_access_currency: Option<String>, //TODO: Some form of char(3). We should check this in the impl.
    open_access_details: Option<String>,  //TODO: Maybe better as a bool for Radical OA? y/n
    ownership_details: Option<String>,    //TODO: Maybe merge with owners.
                                          //TODO: institutional agreements
}

#[juniper::object(description = "A Journal and its OA/Profit Details")]
impl Journal {
    pub fn name(&self) -> &str {
        self.name.as_str()
    }

    pub fn url(&self) -> Option<Url> {
        match &self.url {
            Some(s) => Url::parse(&s).ok(),
            None => None,
        }
    }

    pub fn publisher(&self) -> Publisher {
        use crate::schema::publishers::dsl::*;
        let connection = establish_connection();
        publishers
            .filter(id.eq(self.publisher_id))
            .first::<Publisher>(&connection)
            .expect("Error locating publisher")
    }

    pub fn for_profit(&self) -> bool {
        self.for_profit
    }

    pub fn open_access_fee(&self) -> Option<i32> {
        self.open_access_fee
    }

    pub fn open_access_currency(&self) -> &Option<String> {
        &self.open_access_currency //TODO: Length check? Maybe not needed since it's constrained at the DB level.
    }

    pub fn open_access_details(&self) -> &Option<String> {
        &self.open_access_details
    }

    pub fn ownership_details(&self) -> &Option<String> {
        &self.ownership_details
    }
}

pub struct QueryRoot;

fn establish_connection() -> PgConnection {
    dotenv().ok();
    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    PgConnection::establish(&database_url)
        .unwrap_or_else(|_| panic!("Error connecting to {}", database_url))
}

#[juniper::object]
impl QueryRoot {
    fn publishers() -> Vec<Publisher> {
        use crate::schema::publishers::dsl::*;
        let connection = establish_connection();
        publishers
            .limit(100)
            .load::<Publisher>(&connection)
            .expect("Error loading publishers")
    }
    fn journals() -> Vec<Journal> {
        use crate::schema::journals::dsl::*;
        let connection = establish_connection();
        journals
            .limit(100)
            .load::<Journal>(&connection)
            .expect("Error loading journals")
    }
}

pub struct MutationRoot;

#[juniper::object]
impl MutationRoot {
    fn create_publisher(data: NewPublisher) -> Publisher {
        let connection = establish_connection();
        diesel::insert_into(publishers::table)
            .values(&data)
            .get_result(&connection)
            .expect("Error saving new journal")
    }
}

#[derive(juniper::GraphQLInputObject, Insertable)]
#[table_name = "publishers"]
pub struct NewPublisher {
    pub name: String,
}

pub type Schema = RootNode<'static, QueryRoot, MutationRoot>;

pub fn create_schema() -> Schema {
    Schema::new(QueryRoot {}, MutationRoot {})
}
