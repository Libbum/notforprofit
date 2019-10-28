table! {
    categories (id) {
        id -> Int4,
        focus -> Varchar,
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
    }
}

table! {
    journals (id) {
        id -> Int4,
        name -> Varchar,
        url -> Nullable<Text>,
        publisher_id -> Int4,
        for_profit -> Bool,
        open_access_fee -> Nullable<Int8>,
        open_access_currency -> Nullable<Varchar>,
        open_access_details -> Nullable<Varchar>,
        ownership_details -> Nullable<Text>,
    }
}

table! {
    owners (id) {
        id -> Int4,
        name -> Varchar,
    }
}

table! {
    publishers (id) {
        id -> Int4,
        name -> Varchar,
    }
}

joinable!(journal_categories -> categories (category_id));
joinable!(journal_categories -> journals (journal_id));
joinable!(journal_owners -> journals (journal_id));
joinable!(journal_owners -> owners (owner_id));
joinable!(journals -> publishers (publisher_id));

allow_tables_to_appear_in_same_query!(
    categories,
    journal_categories,
    journal_owners,
    journals,
    owners,
    publishers,
);
