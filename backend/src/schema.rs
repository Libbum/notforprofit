table! {
    categories (id) {
        id -> Int4,
        focus -> Varchar,
    }
}

table! {
    currencies (code) {
        code -> Varchar,
        symbol -> Varchar,
        name -> Varchar,
    }
}

table! {
    fee_categories (id) {
        id -> Int4,
        category -> Varchar,
    }
}

table! {
    fees (id) {
        id -> Int4,
        journal_id -> Int4,
        fee -> Int4,
        currency_code -> Varchar,
        category_id -> Int4,
    }
}

table! {
    journal_categories (journal_id, category_id) {
        journal_id -> Int4,
        category_id -> Int4,
    }
}

table! {
    journal_owners (journal_id, owner_id) {
        journal_id -> Int4,
        owner_id -> Int4,
        ownership_url -> Text,
    }
}

table! {
    journals (id) {
        id -> Int4,
        name -> Varchar,
        url -> Nullable<Text>,
        publisher_id -> Int4,
        for_profit -> Bool,
        publication_model_id -> Int4,
        comments -> Nullable<Text>,
    }
}

table! {
    owners (id) {
        id -> Int4,
        name -> Varchar,
        url -> Nullable<Text>,
    }
}

table! {
    publication_models (id) {
        id -> Int4,
        model -> Varchar,
    }
}

table! {
    publisher_owners (publisher_id, owner_id) {
        publisher_id -> Int4,
        owner_id -> Int4,
    }
}

table! {
    publishers (id) {
        id -> Int4,
        name -> Varchar,
        url -> Nullable<Text>,
        comments -> Nullable<Text>,
    }
}

joinable!(fees -> currencies (currency_code));
joinable!(fees -> fee_categories (category_id));
joinable!(fees -> journals (journal_id));
joinable!(journal_categories -> categories (category_id));
joinable!(journal_categories -> journals (journal_id));
joinable!(journal_owners -> journals (journal_id));
joinable!(journal_owners -> owners (owner_id));
joinable!(journals -> publication_models (publication_model_id));
joinable!(journals -> publishers (publisher_id));
joinable!(publisher_owners -> owners (owner_id));
joinable!(publisher_owners -> publishers (publisher_id));

allow_tables_to_appear_in_same_query!(
    categories,
    currencies,
    fee_categories,
    fees,
    journal_categories,
    journal_owners,
    journals,
    owners,
    publication_models,
    publisher_owners,
    publishers,
);
