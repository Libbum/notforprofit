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
        radical_open_access -> Nullable<Bool>,
        comments -> Nullable<Text>,
    }
}

table! {
    open_access_fees (id) {
        id -> Int4,
        journal_id -> Int4,
        fee -> Int4,
        currency -> Varchar,
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

joinable!(journal_categories -> categories (category_id));
joinable!(journal_categories -> journals (journal_id));
joinable!(journal_owners -> journals (journal_id));
joinable!(journal_owners -> owners (owner_id));
joinable!(journals -> publishers (publisher_id));
joinable!(open_access_fees -> journals (journal_id));
joinable!(publisher_owners -> owners (owner_id));
joinable!(publisher_owners -> publishers (publisher_id));

allow_tables_to_appear_in_same_query!(
    categories,
    journal_categories,
    journal_owners,
    journals,
    open_access_fees,
    owners,
    publisher_owners,
    publishers,
);
