table! {
    addresses (id) {
        id -> Int4,
        line1 -> Varchar,
        line2 -> Nullable<Varchar>,
        line3 -> Nullable<Varchar>,
        city -> Nullable<Varchar>,
        state_province -> Nullable<Varchar>,
        postal_code -> Nullable<Varchar>,
        country_id -> Varchar,
        location -> Nullable<Point>,
        other_details -> Nullable<Varchar>,
    }
}

table! {
    businesses (id) {
        id -> Int4,
        name -> Varchar,
        sector_id -> Int4,
        scale -> Reach,
        address_id -> Int4,
        url -> Nullable<Text>,
        notes -> Nullable<Text>,
    }
}

table! {
    countries (id) {
        id -> Varchar,
        name -> Varchar,
    }
}

table! {
    sectors (id) {
        id -> Int4,
        description -> Nullable<Text>,
    }
}

joinable!(addresses -> countries (country_id));
joinable!(businesses -> addresses (address_id));
joinable!(businesses -> sectors (sector_id));

allow_tables_to_appear_in_same_query!(
    addresses,
    businesses,
    countries,
    sectors,
);
