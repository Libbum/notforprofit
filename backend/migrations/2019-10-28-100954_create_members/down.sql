DROP TABLE if exists journals cascade;
DROP TABLE if exists publishers cascade;
DROP TABLE if exists owners cascade;
DROP TABLE if exists categories cascade;
DROP TRIGGER radical_oa_check ON open_access_fees;
DROP TABLE if exists open_access_fees cascade;
DROP TABLE journal_categories;
DROP TABLE journal_owners;
DROP TABLE publisher_owners;
