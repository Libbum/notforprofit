table! {
    use diesel::sql_types::*;
    use crate::enums::*;

    categories (id) {
        id -> Int4,
        focus -> Varchar,
    }
}

table! {
    use diesel::sql_types::*;
    use crate::enums::*;

    currencies (code) {
        code -> Varchar,
        symbol -> Varchar,
        name -> Varchar,
    }
}

table! {
    use diesel::sql_types::*;
    use crate::enums::*;

    fees (id) {
        id -> Int4,
        journal_id -> Int4,
        fee -> Int4,
        currency_code -> Varchar,
        category -> Fee_category,
    }
}

table! {
    use diesel::sql_types::*;
    use crate::enums::*;

    institutional_agreements (institution_id, publisher_id) {
        institution_id -> Int4,
        publisher_id -> Int4,
        agreement -> Maybe_logic,
        details -> Nullable<Varchar>,
        url -> Nullable<Varchar>,
    }
}

table! {
    use diesel::sql_types::*;
    use crate::enums::*;

    institutions (id) {
        id -> Int4,
        name -> Varchar,
        url -> Nullable<Varchar>,
    }
}

table! {
    use diesel::sql_types::*;
    use crate::enums::*;

    journal_categories (journal_id, category_id) {
        journal_id -> Int4,
        category_id -> Int4,
    }
}

table! {
    use diesel::sql_types::*;
    use crate::enums::*;

    journal_owners (journal_id, owner_id) {
        journal_id -> Int4,
        owner_id -> Int4,
    }
}

table! {
    use diesel::sql_types::*;
    use crate::enums::*;

    journals (id) {
        id -> Int4,
        name -> Varchar,
        url -> Nullable<Text>,
        publisher_id -> Int4,
        for_profit -> Bool,
        comments -> Nullable<Text>,
    }
}

table! {
    use diesel::sql_types::*;
    use crate::enums::*;

    owners (id) {
        id -> Int4,
        name -> Varchar,
        ownership_url -> Nullable<Text>,
        comments -> Nullable<Text>,
    }
}

table! {
    use diesel::sql_types::*;
    use crate::enums::*;

    publication_models (journal_id, publication_model) {
        journal_id -> Int4,
        publication_model -> Publication_model,
    }
}

table! {
    use diesel::sql_types::*;
    use crate::enums::*;

    publisher_owners (publisher_id, owner_id) {
        publisher_id -> Int4,
        owner_id -> Int4,
    }
}

table! {
    use diesel::sql_types::*;
    use crate::enums::*;

    publishers (id) {
        id -> Int4,
        name -> Varchar,
        url -> Nullable<Text>,
        comments -> Nullable<Text>,
    }
}

joinable!(fees -> currencies (currency_code));
joinable!(fees -> journals (journal_id));
joinable!(institutional_agreements -> institutions (institution_id));
joinable!(institutional_agreements -> publishers (publisher_id));
joinable!(journal_categories -> categories (category_id));
joinable!(journal_categories -> journals (journal_id));
joinable!(journal_owners -> journals (journal_id));
joinable!(journal_owners -> owners (owner_id));
joinable!(journals -> publishers (publisher_id));
joinable!(publication_models -> journals (journal_id));
joinable!(publisher_owners -> owners (owner_id));
joinable!(publisher_owners -> publishers (publisher_id));

allow_tables_to_appear_in_same_query!(
    categories,
    currencies,
    fees,
    institutional_agreements,
    institutions,
    journal_categories,
    journal_owners,
    journals,
    owners,
    publication_models,
    publisher_owners,
    publishers,
);
