CREATE TABLE publishers (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR NOT NULL,
    url TEXT,
    comments TEXT
);

--TODO: Read only access to users
CREATE TABLE publication_models (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    model VARCHAR NOT NULL
);

CREATE TABLE journals (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR NOT NULL,
    url TEXT,
    publisher_id INT NOT NULL,
    -- Owner is M2M
    for_profit BOOLEAN NOT NULL,
    -- Fees are M2M
    publication_model_id INT NOT NULL,
    -- TODO institutional agreements.
    -- Think a M2M system would be better than just SU, which is done atm.
    -- Agreements need to cover at least y/n/?/na/discout(value), and perhaps more.
    -- Category is M2M
    comments TEXT,
    FOREIGN KEY (publisher_id) REFERENCES publishers(id),
    FOREIGN KEY (publication_model_id) REFERENCES publication_models(id)
);

--TODO: Read only access to users
CREATE TABLE currencies (
    code VARCHAR UNIQUE NOT NULL PRIMARY KEY CHECK (length(code) = 3),
    symbol VARCHAR NOT NULL,
    name VARCHAR NOT NULL
);

--TODO: Read only access to users
CREATE TABLE fee_categories (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category VARCHAR NOT NULL
);

CREATE TABLE fees (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    journal_id INT NOT NULL,
    fee INT NOT NULL CHECK (fee >= 0),
    currency_code VARCHAR NOT NULL CHECK (length(currency_code) = 3),
    category_id INT NOT NULL,
    FOREIGN KEY (journal_id) REFERENCES journals(id),
    FOREIGN KEY (currency_code) REFERENCES currencies(code),
    FOREIGN KEY (category_id) REFERENCES fee_categories(id)
);

CREATE TABLE owners (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR NOT NULL,
    url TEXT
    -- TODO: Useful details on owners. Net worth, company/individual? etc.
);

CREATE TABLE publisher_owners (
    publisher_id INT NOT NULL,
    owner_id INT NOT NULL,
    FOREIGN KEY (publisher_id) REFERENCES publishers(id),
    FOREIGN KEY (owner_id) REFERENCES owners(id),
    PRIMARY KEY (publisher_id, owner_id)
);

CREATE TABLE journal_owners (
    journal_id INT NOT NULL,
    owner_id INT NOT NULL,
    ownership_url TEXT NOT NULL,
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

/*CREATE OR REPLACE FUNCTION radical_oa_check() RETURNS trigger AS $radical_oa_check$
    BEGIN
        -- Check that the journal has a radical open access value.
        -- If it doesn't, and we have a sum of 0 for fees, assume radical OA
        IF ( ( SELECT SUM(fee) FROM open_access_fees WHERE journal_id = NEW.journal_id ) = 0 )
           AND
           ( ( SELECT radical_open_access FROM journals WHERE id = NEW.journal_id ) = NULL ) THEN
            UPDATE journals SET radical_open_access = True WHERE id = NEW.journal_id;
        END IF;

        RETURN NEW;
    END;
$radical_oa_check$ LANGUAGE plpgsql;

CREATE TRIGGER radical_oa_check AFTER INSERT OR UPDATE OR DELETE ON open_access_fees
    FOR EACH ROW EXECUTE PROCEDURE radical_oa_check();*/

--TODO: These are the most popular, but we should put the entire list in probably.
-- ISO 4217
INSERT INTO currencies(code, symbol, name) VALUES ('USD', '$', 'US Dollar'),
                                                  ('EUR', '€', 'Euro'),
                                                  ('GBP', '£', 'British Pound'),
                                                  ('SEK', 'kr', 'Swedish Krona'),
                                                  ('INR', '₹', 'Indian Rupee'),
                                                  ('AUD', '$', 'Australian Dollar'),
                                                  ('CAD', '$', 'Canadian Dollar'),
                                                  ('SGD', '$', 'Singapore Dollar'),
                                                  ('CHF', 'CHF', 'Swiss Franc'),
                                                  ('MYR', 'RM', 'Malaysian Ringgit'),
                                                  ('JPY', '¥', 'Japanese Yen'),
                                                  ('NZD', '$', 'New Zealand Dollar'),
                                                  ('MXN', '$', 'Mexican Peso'),
                                                  ('CNY', '¥', 'Chinese Yuan Renminbi');

INSERT INTO fee_categories(category) VALUES ('ArticleProcessingCharge'), --Explicitly for OA
                                            ('Publication'), --Charges for publication, generally in closed models e.g. https://www.pnas.org/page/authors/fees
                                            ('Subscription'), --Yearly fee for access
                                            ('PayPerView'); --Single paper access


INSERT INTO publication_models(model) VALUES ('Subscription'), --Closed, not OA
                                             ('BronzeOpenAccess'), --Delayed OA, Closed for a period of time, then released as OA in some form
                                             ('HybridOpenAccess'), --'Open Choice' puts burden on authors to pay for open access, otherwise closed
                                             ('GreenOpenAccess'), --Allows self-archiving of authors work outside of the journals garden
                                             ('GoldOpenAccess'), --All content open for free and immediately for viewing. Usually under CC.
                                             ('PlatinumOpenAcess'); --Same as Gold, but do not charge the authors an APC.


INSERT INTO publishers(name, url, comments) VALUES ('IOP Publishing','https://ioppublishing.org/','Publically available Environmental Policy, Modern Day Slavery Policy & Gender Pay Gap statistics for organisation');
INSERT INTO owners(name, url) VALUES ('Institute of Physics', 'http://www.iop.org/'),
                                     ('Deutsche Physikalische Gesellschaft', 'https://www.dpg-physik.de/');
INSERT INTO categories(focus) VALUES ('Physics');
INSERT INTO journals(name, url, publisher_id, for_profit, publication_model_id) VALUES ('New Journal of Physics', 'https://iopscience.iop.org/journal/1367-2630', 1, False, 5);
INSERT INTO fees(journal_id, fee, currency_code, category_id) VALUES (1, 1400, 'GBP', 1), (1, 1600, 'EUR', 1), (1, 2100, 'USD', 1);
INSERT INTO journal_owners(journal_id, owner_id, ownership_url) VALUES (1, 1, 'https://beta.iop.org/governance'), (1, 2, 'https://www.dpg-physik.de/ueber-uns');
INSERT INTO journal_categories(journal_id, category_id) VALUES (1, 1);
