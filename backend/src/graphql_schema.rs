extern crate dotenv;
use std::env;

use diesel::pg::PgConnection;
use diesel::prelude::*;
use dotenv::dotenv;
use juniper::RootNode;
use url::Url;

use crate::schema::publishers;
use crate::enums::*;

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
    /// Official name of the publisher
    pub fn name(&self) -> &str {
        self.name.as_str()
    }

    /// Homepage of the publisher
    pub fn url(&self) -> Option<Url> {
        match &self.url {
            Some(s) => Url::parse(&s).ok(),
            None => None,
        }
    }

    /// A list of owners of this publisher, along side ownership details
    pub fn owners(&self) -> Vec<Owner> {
        use crate::schema::owners::dsl::*;
        use crate::schema::publisher_owners::dsl::*;
        let connection = establish_connection();
        publisher_owners
            .inner_join(owners)
            .filter(publisher_id.eq(self.id))
            .select((id, name, ownership_url, comments))
            .load::<Owner>(&connection)
            .expect("Error locating ownership information")
    }

    /// What publication models does this publisher provide?
    pub fn publication_models(&self) -> Vec<PublicationModel> {
        use crate::schema::publication_models::dsl::*;
        let connection = establish_connection();
        publication_models
            .filter(publisher_id.eq(self.id))
            .select(publication_model)
            .load::<PublicationModel>(&connection)
            .expect("Error locating publication model information")
    }

    /// Any additional comments about this publisher that may be pertinent
    pub fn comments(&self) -> &Option<String> {
        &self.comments
    }

    /// Publishing agreements set out by various Universities
    pub fn institutional_agreements() -> Vec<PublisherAgreement> {
        use crate::schema::institutional_agreements::dsl::*;
        use crate::schema::{institutions, publishers};
        let connection = establish_connection();
        institutional_agreements
            .inner_join(institutions::table)
            .inner_join(publishers::table)
            .filter(publisher_id.eq(&self.id))
            .select((institutions::name, agreement, details, url))
            .load::<PublisherAgreement>(&connection)
            .expect("Error loading Institutional Agreements")
    }
}


#[derive(Queryable)]
pub struct Owner {
    #[allow(unused)]
    id: i32,
    name: String,
    ownership_url: Option<String>,
    comments: Option<String>,
}

#[juniper::object(description = "Owner of a Publisher or Journal")]
impl Owner {
    /// Official name of the owner of a publisher (or journal)
    pub fn name(&self) -> &str {
        self.name.as_str()
    }

    /// A URL attributing ownership of a publisher (or journal) to this owner
    pub fn ownership_url(&self) -> Option<Url> {
        match &self.ownership_url {
            Some(s) => Url::parse(&s).ok(),
            None => None,
        }
    }

    /// Additional comments pertinent to this owner
    pub fn comments(&self) -> &Option<String> {
        &self.comments
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
    comments: Option<String>,
}

#[juniper::object(description = "A Journal and its OA/Profit Details")]
impl Journal {
    /// Name of journal
    pub fn name(&self) -> &str {
        self.name.as_str()
    }

    /// Homepage of journal
    pub fn url(&self) -> Option<Url> {
        match &self.url {
            Some(s) => Url::parse(&s).ok(),
            None => None,
        }
    }

    /// The publisher of this journal along with the publisher's details
    pub fn publisher(&self) -> Publisher {
        use crate::schema::publishers::dsl::*;
        let connection = establish_connection();
        publishers
            .filter(id.eq(self.publisher_id))
            .first::<Publisher>(&connection)
            .expect("Error locating publisher")
    }

    /// 99% of the time, a journal's ownership is via the publisher. In rare circumstances however, additional entities may have partial stake in a single journal.
    pub fn additional_owners(&self) -> Vec<Owner> {
        use crate::schema::owners::dsl::*;
        use crate::schema::journal_owners::dsl::*;
        let connection = establish_connection();
        journal_owners
            .inner_join(owners)
            .filter(journal_id.eq(self.id))
            .select((id, name, ownership_url, comments))
            .load::<Owner>(&connection)
            .expect("Error locating ownership information")

    }

    /// Is the journal a for-profit enterprise?
    pub fn for_profit(&self) -> bool {
        self.for_profit
    }

    /// Set of known fees for this journal
    pub fn fees(&self) -> Vec<Fee> {
        use crate::schema::fees::dsl::*;
        let connection = establish_connection();
        fees
            .filter(journal_id.eq(self.id))
            .load::<Fee>(&connection)
            .expect("Error locating Fee data")
    }

    /// A list of categories this journal caters for
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

    /// Any additional comments needed for this specific journal
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
    category: FeeCategory,
}

#[juniper::object(description = "Journal fees for various access modes in published currencies")]
impl Fee {
    /// The journal that this fee is associated with
    pub fn journal(&self) -> Journal {
        use crate::schema::journals::dsl::*;
        let connection = establish_connection();
        journals
            .filter(id.eq(self.journal_id))
            .first::<Journal>(&connection)
            .expect("Error locating journal")
    }

    /// Current rate, needs to be associated with a specific currency
    pub fn fee(&self) -> i32 {
        self.fee
    }

    /// The currency for which this fee is valued
    pub fn currency(&self) -> Currency {
        use crate::schema::currencies::dsl::*;
        let connection = establish_connection();
        currencies
            .filter(code.eq(&self.currency_code))
            .first::<Currency>(&connection)
            .expect("Error locating currency details")
    }

    /// What form of fee is this?
    pub fn category(&self) -> &FeeCategory {
        &self.category
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
    /// ISO 4217 country code for this currency
    pub fn code(&self) -> &str {
        self.code.as_str()
    }

    /// The currencies associated symbol
    pub fn symbol(&self) -> &str {
        self.symbol.as_str()
    }

    /// Name of currency in English
    pub fn name(&self) -> &str {
        self.name.as_str()
    }
}

#[derive(Queryable)]
pub struct PublisherAgreement {
    institution: String,
    agreement: MaybeLogic,
    details: Option<String>,
    url: Option<String>,
}

#[juniper::object(description = "Agreement between a Publisher and Institute")]
impl PublisherAgreement {
    /// Name of institution for which this agreement is for
    pub fn institution(&self) -> &str {
        self.institution.as_str()
    }

    /// Has an agreement been made? Or is one even required?
    pub fn agreement(&self) -> &MaybeLogic {
        &self.agreement
    }

    /// Additional information about the agreement if needed
    pub fn details(&self) -> &Option<String> {
        &self.details
    }

    /// URL of agreement to verify specifics
    pub fn url(&self) -> &Option<String> {
        &self.url
    }
}

#[derive(Queryable)]
pub struct Agreement {
    institution: String,
    publisher: String,
    agreement: MaybeLogic,
    details: Option<String>,
    url: Option<String>,
}

#[juniper::object(description = "Agreement between a Publisher and Institute")]
impl Agreement {
    /// Name of institution for which this agreement is for
    pub fn institution(&self) -> &str {
        self.institution.as_str()
    }

    /// Name of the publisher associated with this agreement
    pub fn publisher(&self) -> &str {
        self.publisher.as_str()
    }

    /// Has an agreement been made? Or is one even required?
    pub fn agreement(&self) -> &MaybeLogic {
        &self.agreement
    }

    /// Additional information about the agreement if needed
    pub fn details(&self) -> &Option<String> {
        &self.details
    }

    /// URL of agreement to verify specifics
    pub fn url(&self) -> &Option<String> {
        &self.url
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
    /// List all publishers in the database
    fn publishers() -> Vec<Publisher> {
        use crate::schema::publishers::dsl::*;
        let connection = establish_connection();
        publishers
            .limit(100)
            .load::<Publisher>(&connection)
            .expect("Error loading publishers")
    }
    /// List all publishers in the database
    fn owners() -> Vec<Owner> {
        use crate::schema::owners::dsl::*;
        let connection = establish_connection();
        owners
            .limit(100)
            .load::<Owner>(&connection)
            .expect("Error loading owners")
    }
    /// List all journals in the database
    fn journals() -> Vec<Journal> {
        use crate::schema::journals::dsl::*;
        let connection = establish_connection();
        journals
            .limit(100)
            .load::<Journal>(&connection)
            .expect("Error loading journals")
    }
    /// List all fees in the database
    fn fees() -> Vec<Fee> {
        use crate::schema::fees::dsl::*;
        let connection = establish_connection();
        fees
            .limit(100)
            .load::<Fee>(&connection)
            .expect("Error loading OA Fees")
    }
    /// List all institutional agreements in the database
    fn institutional_agreements() -> Vec<Agreement> {
        use crate::schema::institutional_agreements::dsl::*;
        use crate::schema::{institutions, publishers};
        let connection = establish_connection();
        institutional_agreements
            .inner_join(institutions::table)
            .inner_join(publishers::table)
            .select((institutions::name, publishers::name, agreement, details, url))
            .limit(100)
            .load::<Agreement>(&connection)
            .expect("Error loading Institutional Agreements")
    }
    /// List all categories in the database
    fn categories() -> Vec<String> {
        use crate::schema::categories::dsl::*;
        let connection = establish_connection();
        categories
            .select(focus)
            .limit(100)
            .load::<String>(&connection)
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
