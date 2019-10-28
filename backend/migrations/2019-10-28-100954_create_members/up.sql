CREATE TABLE publishers (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR NOT NULL
    -- TODO: URL, Other useful info
);

CREATE TABLE journals (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR NOT NULL,
    url TEXT,
    publisher_id INT NOT NULL,
    -- Owner is M2M
    for_profit BOOLEAN NOT NULL,
    open_access_fee BIGINT CHECK (open_access_fee >= 0), --TODO: Proper currency conversion.
    open_access_currency VARCHAR CHECK (length(open_access_currency) = 3),
    open_access_details VARCHAR, -- TODO: This may be better as a bool for Radical OA y/n.
    ownership_details TEXT, --TODO: This is not the best. Might be better to merge details of owners, and put this information in their tables.
    -- TODO institutional agreements.
    -- Think a M2M system would be better than just SU, which is done atm.
    -- Agreements need to cover at least y/n/?/na/discout(value), and perhaps more.
    -- Category is M2M
    FOREIGN KEY (publisher_id) REFERENCES publishers(id),
    CONSTRAINT open_access_free_without_details CHECK (
        NOT (
                ( open_access_fee = 0::BIGINT )
                AND
                ( open_access_details IS NULL  OR  open_access_details = '' )
        )
    )
);

CREATE TABLE owners (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR NOT NULL
    -- TODO: Useful details on owners. Net worth, company/individual? etc.
);

CREATE TABLE journal_owners (
    journal_id INT NOT NULL,
    owner_id INT NOT NULL,
    FOREIGN KEY (journal_id) REFERENCES journals(id),
    FOREIGN KEY (owner_id) REFERENCES owners(id),
    PRIMARY KEY (journal_id, owner_id)
);

CREATE TABLE categories (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    focus VARCHAR NOT NULL
);

CREATE TABLE journal_categories (
    journal_id INT NOT NULL,
    category_id INT NOT NULL,
    FOREIGN KEY (journal_id) REFERENCES journals(id),
    FOREIGN KEY (category_id) REFERENCES categories(id),
    PRIMARY KEY (journal_id, category_id)
);

INSERT INTO publishers(name) VALUES ('IOP Science');
INSERT INTO owners(name) VALUES ('Institute of Physics');
INSERT INTO owners(name) VALUES ('Deutsche Physikalische Gesellschaft');
INSERT INTO categories(focus) VALUES ('Physics');
INSERT INTO journals(name, url, publisher_id, for_profit, open_access_fee, open_access_currency, ownership_details) VALUES ('New Journal of Physics', 'https://iopscience.iop.org/journal/1367-2630', 1, False, 1600, 'EUR', 'https://beta.iop.org/governance, https://www.dpg-physik.de/ueber-uns');
INSERT INTO journal_owners(journal_id, owner_id) VALUES (1, 1);
INSERT INTO journal_owners(journal_id, owner_id) VALUES (1, 2);
INSERT INTO journal_categories(journal_id, category_id) VALUES (1, 1);
