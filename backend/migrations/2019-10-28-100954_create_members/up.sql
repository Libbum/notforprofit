CREATE TYPE maybe_logic AS ENUM ('yes', 'no', 'unknown', 'not_needed');
CREATE TYPE fee_category AS ENUM ('article_processing_charge', --Explicitly for OA
                                  'publication', --Charges for publication, generally in closed models e.g. https://www.pnas.org/page/authors/fees
                                  'subscription', --Yearly fee for access
                                  'pay_per_view'); --Single paper access
CREATE TYPE publication_model AS ENUM ('subscription', --Closed, not OA
                                       'bronze_open_access', --Delayed OA, Closed for a period of time, then released as OA in some form
                                       'hybrid_open_access', --'Open Choice' puts burden on authors to pay for open access, otherwise closed
                                       'green_open_access', --Allows self-archiving of authors work outside of the journals garden
                                       'gold_open_access', --All content open for free and immediately for viewing. Usually under CC.
                                       'platinum_open_acess'); --Same as Gold, but do not charge the authors an APC.
CREATE TABLE publishers (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR NOT NULL,
    url TEXT,
    comments TEXT
);

CREATE TABLE journals (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR NOT NULL,
    url TEXT,
    publisher_id INT NOT NULL,
    -- Owner is M2M
    for_profit BOOLEAN NOT NULL,
    -- Fees are M2M
    publication_model publication_model NOT NULL,
    --TODO: license details
    -- Category is M2M
    comments TEXT,
    FOREIGN KEY (publisher_id) REFERENCES publishers(id)
);

--TODO: Read only access to users
CREATE TABLE currencies (
    code VARCHAR UNIQUE NOT NULL PRIMARY KEY CHECK (length(code) = 3),
    symbol VARCHAR NOT NULL,
    name VARCHAR NOT NULL
);

CREATE TABLE fees (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    journal_id INT NOT NULL,
    fee INT NOT NULL CHECK (fee >= 0),
    currency_code VARCHAR NOT NULL CHECK (length(currency_code) = 3),
    category fee_category NOT NULL,
    FOREIGN KEY (journal_id) REFERENCES journals(id),
    FOREIGN KEY (currency_code) REFERENCES currencies(code)
);

CREATE TABLE owners (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR NOT NULL,
    publisher_ownership_url TEXT,
    comments TEXT --TODO: This is a dumping ground ATM, should work to separate it.
    -- TODO: Useful details on owners. Net worth, company/individual? etc.
);

CREATE TABLE publisher_owners (
    publisher_id INT NOT NULL,
    owner_id INT NOT NULL,
    FOREIGN KEY (publisher_id) REFERENCES publishers(id),
    FOREIGN KEY (owner_id) REFERENCES owners(id),
    PRIMARY KEY (publisher_id, owner_id)
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

CREATE TABLE institutions (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR NOT NULL,
    url VARCHAR
);

CREATE TABLE institutional_agreements (
    institution_id INT NOT NULL,
    journal_id INT NOT NULL,
    agreement maybe_logic NOT NULL,
    details VARCHAR, -- For example: "25% Discount"
    url VARCHAR,
    PRIMARY KEY (institution_id, journal_id),
    FOREIGN KEY (institution_id) REFERENCES institutions(id),
    FOREIGN KEY (journal_id) REFERENCES journals(id)
);

CREATE FUNCTION publication_model_check() RETURNS trigger AS $publication_model_check$
    DECLARE
        model publication_model;
    BEGIN
        SELECT INTO model publication_model
            FROM journals
            WHERE id = NEW.journal_id;
        CASE model
             WHEN 'green_open_access' THEN
                 IF NEW.category = 'publication' THEN
                     RAISE EXCEPTION 'Green Open Access publications require APC, not Publication fees.';
                 END IF;
             WHEN 'gold_open_access' THEN
                 IF NEW.category <> 'article_processing_charge' THEN
                     RAISE EXCEPTION 'Gold Open Access publications only require APC fees.';
                 END IF;
             WHEN 'platinum_open_acess' THEN
                 RAISE EXCEPTION 'Platinum Open Access publications do not require fees.';
             ELSE
                 IF NEW.category = 'article_processing_charge' THEN
                     RAISE EXCEPTION 'This form of publication cannot have APS fees.';
                 END IF;
        END CASE;

        RETURN NEW;
    END;
$publication_model_check$ LANGUAGE plpgsql;

CREATE TRIGGER publication_model_check BEFORE INSERT OR UPDATE ON fees
    FOR EACH ROW EXECUTE PROCEDURE publication_model_check();

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

-- Categories
INSERT INTO categories(focus) VALUES ('Physics'),
                                     ('Sustainable Economy'),
                                     ('Sustainability'),
                                     ('Not-for-Profit'),
                                     ('Organizational Theory'),
                                     ('Economics'),
                                     ('International Studies'),
                                     ('Environmental Science'),
                                     ('Science'),
                                     ('Technology'),
                                     ('Society'),
                                     ('Culture'),
                                     ('Interdisciplinary Communications');

-- Publishers
INSERT INTO publishers(name, url, comments) VALUES ('IOP Publishing','https://ioppublishing.org/','Publically available Environmental Policy, Modern Day Slavery Policy & Gender Pay Gap statistics for organisation'),
                                                   ('USC Annenberg Press', 'https://annenbergpress.com/', 'University of Southern California');
INSERT INTO publishers(name, url) VALUES ('Taylor and Francis', 'https://taylorandfrancis.com/'),
                                         ('Elsevier', 'https://www.elsevier.com/'),
                                         ('Resilience Alliance', 'https://www.resalliance.org/'),
                                         ('White Horse Press', 'http://www.whp-journals.co.uk/'),
                                         ('Cambridge University Press', 'https://www.cambridge.org/'),
                                         ('Springer', 'https://www.springer.com/'),
                                         ('International Centre for Not-for-Profit Law', 'http://www.icnl.org/'),
                                         ('Oxford University Press', 'https://global.oup.com/'),
                                         ('University of Arizona Press', 'https://uapress.arizona.edu/'),
                                         ('Sage', 'https://www.sagepub.com/'),
                                         ('World Economics Association', 'https://www.worldeconomicsassociation.org/'),
                                         ('MDPI', 'https://www.mdpi.com/'),
                                         ('Wiley Online', 'https://onlinelibrary.wiley.com/'),
                                         ('The Society for Social Studies of Science', 'https://www.4sonline.org/');

-- Journals
INSERT INTO journals(name, url, publisher_id, for_profit, publication_model) VALUES ('New Journal of Physics', 'https://iopscience.iop.org/journal/1367-2630', 1, False, 'gold_open_access');
INSERT INTO fees(journal_id, fee, currency_code, category) VALUES (1, 1400, 'GBP', 'article_processing_charge'), (1, 1600, 'EUR', 'article_processing_charge'), (1, 2100, 'USD', 'article_processing_charge');
INSERT INTO journal_categories(journal_id, category_id) VALUES (1, 1);

-- Institutions
INSERT INTO institutions(name, url) VALUES ('Stockholm University', 'https://www.su.se/');
INSERT INTO institutional_agreements(institution_id, journal_id, agreement, url) VALUES (1, 1, 'yes', 'https://www.su.se/english/library/publish/publish-open-access/iop-institute-of-physics-1.398957');

-- Owners
INSERT INTO owners(name, publisher_ownership_url) VALUES ('Institute of Physics', 'https://oaspa.org/member/iop-publishing/?highlight=iop'),
                                     ('The Society for Social Studies of Science', 'https://estsjournal.org/index.php/ests/about/history'),
                                     ('Resilliance Alliance', 'https://www.guidestar.org/profile/04-3491218'),
                                     ('Cambridge University', 'https://www.cambridge.org/about-us/annual-report'),
                                     ('SpringerNature', 'https://group.springernature.com/gp/group/aboutus/our-history'),
                                     ('ICNL', 'http://www.icnl.org/research/journal/index.html'),
                                     ('Arizona State University', 'https://journals.uair.arizona.edu/index.php/JPE/about/submissions#authorGuidelines'),
                                     ('Oxford University', 'https://www.ox.ac.uk/about/organisation/university-as-a-charity?wssl=1'),
                                     ('World Economics Association', 'http://www.paecon.net/PAEReview/'),
                                     ('Shu-Kun Lin', 'https://oaspa.org/member/mdpi-ag/');
INSERT INTO owners(name, publisher_ownership_url, comments) VALUES ('Informa PLC', 'https://informa.com/Documents/Investor%20Relations/2019/20190524%20AGM%20Trading%20Update.pdf', 'Publically Traded'),
                                     ('RELX', 'https://www.relx.com/investors/share-price/lse', 'Publically Traded'),
                                     ('Deutsche Physikalische Gesellschaft', 'https://www.dpg-physik.de/ueber-uns/', 'Connected to Institute of Physics as part owner of (at least) the New Journal of Physics'),
                                     ('White Horse Press LLP', 'https://whitehorsepress.blog/', 'Owned by Sarah, Andrew and Alison Johnson'),
                                     ('BC Partners', 'https://www.bcpartners.com/private-equity-strategy/portfolio/springer-nature', 'Private equity firm. Main shareholder of SpringerNature'),
                                     ('Holtzbrinck Publishing Group', 'https://www.holtzbrinck.com', 'Georg von Holtzbrinck, 53% shareholder of SpringerNature'),
                                     ('Sarah Miller McCune', 'https://uk.sagepub.com/sites/default/files/a1501001_sage_story-50_june2015_final_lo-res.pdf', 'Will be converted into a foundation after she dies (page 57 in "History of Sage" of attached URL'),
                                     ('John Wiley & Sons, Inc', 'https://www.wiley.com/en-us/investors', 'Publically Traded'),
                                     ('University of Southern California', 'https://about.usc.edu/files/2019/02/USC-FY18-Financial-Report.pdf', 'See page 15 of report. Not-for-Profit private university');
INSERT INTO publisher_owners(publisher_id, owner_id) VALUES (1, 1), (1, 13);

