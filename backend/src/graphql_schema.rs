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
    url: Option<String>,
    comments: Option<String>,
}

#[juniper::object(description = "A Journal Publication House")]
impl Publisher {
    pub fn name(&self) -> &str {
        self.name.as_str()
    }

    pub fn url(&self) -> Option<Url> {
        match &self.url {
            Some(s) => Url::parse(&s).ok(),
            None => None,
        }
    }

    pub fn comments(&self) -> &Option<String> {
        &self.comments
    }
}

#[derive(Queryable)]
pub struct Owner {
    #[allow(unused)]
    id: i32,
    name: String,
    url: Option<String>,
}

#[juniper::object(description = "An Owner of a Journal or Publication House")]
impl Owner {
    pub fn name(&self) -> &str {
        self.name.as_str()
    }

    pub fn url(&self) -> Option<Url> {
        match &self.url {
            Some(s) => Url::parse(&s).ok(),
            None => None,
        }
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
    publication_model_id: i32,
    comments: Option<String>,
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

    pub fn owners(&self) -> Vec<Owner> {
        use crate::schema::owners::dsl::*;
        use crate::schema::journal_owners::dsl::*;
        let connection = establish_connection();
        journal_owners
            .inner_join(owners)
            .filter(journal_id.eq(self.id))
            .select((id, name, url))
            .load::<Owner>(&connection)
            .expect("Error locating ownership information")
    }

    pub fn ownership_url(&self) -> Vec<String> {
        use crate::schema::owners::dsl::*;
        use crate::schema::journal_owners::dsl::*;
        let connection = establish_connection();
        let urls: Vec<String> = journal_owners
            .inner_join(owners)
            .filter(journal_id.eq(self.id))
            .select(ownership_url)
            .load(&connection)
            .expect("Error locating ownership information");
        urls //TODO: Parse these to URL types.
    }

    pub fn for_profit(&self) -> bool {
        self.for_profit
    }

    pub fn fees(&self) -> Vec<Fee> {
        use crate::schema::fees::dsl::*;
        let connection = establish_connection();
        fees
            .filter(journal_id.eq(self.id))
            .load::<Fee>(&connection)
            .expect("Error locating Fee data")
    }

    pub fn publication_model(&self) -> String {
        use crate::schema::publication_models::dsl::*;
        let connection = establish_connection();
        publication_models
            .filter(id.eq(&self.publication_model_id))
            .select(model)
            .first::<String>(&connection) //TODO: Enum
            .expect("Error locating Fee data")
    }

    pub fn categories(&self) -> Vec<String> {
        use crate::schema::categories::dsl::*;
        use crate::schema::journal_categories::dsl::*;
        let connection = establish_connection();
        journal_categories
            .inner_join(categories)
            .filter(journal_id.eq(self.id))
            .select(focus)
            .load::<String>(&connection)
            .expect("Error locating Category data")
    }

    pub fn comments(&self) -> &Option<String> {
        &self.comments
    }
}

#[derive(Queryable)]
pub struct Fee {
    #[allow(unused)]
    id: i32,
    journal_id: i32,
    fee: i32,
    currency_code: String,
    category_id: i32,
}

#[juniper::object(description = "Journal fees for various access modes in published currencies")]
impl Fee {
    pub fn journal(&self) -> Journal {
        use crate::schema::journals::dsl::*;
        let connection = establish_connection();
        journals
            .filter(id.eq(self.journal_id))
            .first::<Journal>(&connection)
            .expect("Error locating journal")
    }

    pub fn fee(&self) -> i32 {
        self.fee
    }

    pub fn currency(&self) -> Currency {
        use crate::schema::currencies::dsl::*;
        let connection = establish_connection();
        currencies
            .filter(code.eq(&self.currency_code))
            .first::<Currency>(&connection)
            .expect("Error locating currency details")
    }

    pub fn category(&self) -> String {
        use crate::schema::fee_categories::dsl::*;
        let connection = establish_connection();
        fee_categories
            .filter(id.eq(self.category_id))
            .select(category)
            .first::<String>(&connection) //TODO: Enum
            .expect("Error locating fee category")
    }
}

#[derive(Queryable)]
pub struct Currency {
    code: String,
    symbol: String,
    name: String,
}

#[juniper::object(description = "Details of Currency being used")]
impl Currency {
    pub fn code(&self) -> &str {
        self.code.as_str()
    }

    pub fn symbol(&self) -> &str {
        self.symbol.as_str()
    }

    pub fn name(&self) -> &str {
        self.name.as_str()
    }
}

#[derive(Queryable)]
pub struct Category {
    #[allow(unused)]
    id: i32,
    focus: String,
}

#[juniper::object(description = "Category of interest")]
impl Category {
    pub fn focus(&self) -> &str {
        self.focus.as_str()
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
    fn owners() -> Vec<Owner> {
        use crate::schema::owners::dsl::*;
        let connection = establish_connection();
        owners
            .limit(100)
            .load::<Owner>(&connection)
            .expect("Error loading owners")
    }
    fn journals() -> Vec<Journal> {
        use crate::schema::journals::dsl::*;
        let connection = establish_connection();
        journals
            .limit(100)
            .load::<Journal>(&connection)
            .expect("Error loading journals")
    }
    fn fees() -> Vec<Fee> {
        use crate::schema::fees::dsl::*;
        let connection = establish_connection();
        fees
            .limit(100)
            .load::<Fee>(&connection)
            .expect("Error loading OA Fees")
    }
    fn categories() -> Vec<Category> {
        use crate::schema::categories::dsl::*;
        let connection = establish_connection();
        categories
            .limit(100)
            .load::<Category>(&connection)
            .expect("Error loading categories")
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
    pub url: Option<String>,
    pub comments: Option<String>,
}

pub type Schema = RootNode<'static, QueryRoot, MutationRoot>;

pub fn create_schema() -> Schema {
    Schema::new(QueryRoot {}, MutationRoot {})
}
