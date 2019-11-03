CREATE TYPE maybe_logic AS ENUM ('yes', 'no', 'not_needed');
CREATE TYPE fee_category AS ENUM ('article_processing_charge', --Explicitly for OA
                                  'publication', --Charges for publication, generally in closed models e.g. https://www.pnas.org/page/authors/fees
                                  'subscription', --Yearly fee for access
                                  'pay_per_view'); --Single paper access
CREATE TYPE publication_model AS ENUM ('subscription', --Closed, not OA
                                       'archive', --Not currently accepting submissions
                                       'bronze_open_access', --Delayed OA, Closed for a period of time, then released as OA in some form
                                       'hybrid_open_access', --'Open Choice/Open Select' puts burden on authors to pay for open access, otherwise closed
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
    --TODO: license details? Perhaps not needed. Most OA is under CC of some description, generally as authors choice. Sometimes there is lockin, but seldom.
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

--TODO: Agreements seem to be between pubilsers and the university & not associated with a journal directly. May want to swap this to align with the publisers.
--TODO: Define agreement a little better. We have access to some of these journals through subscriptions, and we also (possibly) have agreements for OA APC discounts or something else.
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
             WHEN 'hybrid_open_access' THEN
                -- Nothing. APCs can exist here, as well as Publication fees.
                RETURN NEW;
                IF NEW.category = 'article_processing_charge' THEN
                    RAISE EXCEPTION 'Fell through';
                END IF;
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
INSERT INTO publishers(name, url) VALUES ('Taylor and Francis', 'https://taylorandfrancis.com/'), --Seems to have blanket hybrid OA, an APC for gold OA, and an ageement on green OA that seems to be moreso brown OA. https://authorservices.taylorandfrancis.com/publishing-open-access/#GreenOA
                                         ('Elsevier', 'https://www.elsevier.com/'), --Seems to be that when OA is accessible, Gold or subscription is offered. Thus we mark as HybridOA
                                         ('Resilience Alliance', 'https://www.resalliance.org/'),
                                         ('White Horse Press', 'http://www.whp-journals.co.uk/'),
                                         ('Cambridge University Press', 'https://www.cambridge.org/'),
                                         ('Springer', 'https://www.springer.com/'), -- List of all SpringerNature OA journals, license and pricing: https://www.springernature.com/gp/open-research/journals-books/journals
                                         ('International Centre for Not-for-Profit Law', 'http://www.icnl.org/'),
                                         ('Oxford University Press', 'https://global.oup.com/'),
                                         ('University of Arizona Press', 'https://uapress.arizona.edu/'),
                                         ('Sage', 'https://www.sagepub.com/'), -- Sage seems to provide 'sage choice', gold/subscription
                                         ('World Economics Association', 'https://www.worldeconomicsassociation.org/'),
                                         ('MDPI', 'https://www.mdpi.com/'),
                                         ('Wiley Online', 'https://onlinelibrary.wiley.com/'),
                                         ('The Society for Social Studies of Science', 'https://www.4sonline.org/');

-- Journals
INSERT INTO journals(name, url, publisher_id, for_profit, publication_model) VALUES ('New Journal of Physics', 'https://iopscience.iop.org/journal/1367-2630', 1, False, 'gold_open_access'),
    ('Capitalism, Nature and Socialism', 'https://www.tandfonline.com/loi/rcns20', 3, True, 'hybrid_open_access'),
    ('Ecological Economics', 'https://www.journals.elsevier.com/ecological-economics', 4, True, 'hybrid_open_access'),
    ('Ecology and Society', 'https://www.ecologyandsociety.org/', 5, False, 'gold_open_access'), --CC BY-NC 4.0
    ('Environmental Values', 'http://www.whpress.co.uk/EV.html', 6, True, 'green_open_access'), --And gold_open_access. Green for free, gold for payment. Need to redesign this :/
    ('Futures', 'https://www.journals.elsevier.com/futures', 4, True, 'hybrid_open_access'),
    ('Global Sustainability', 'https://www.cambridge.org/core/journals/global-sustainability', 7, False, 'gold_open_access'),
    ('Human Ecology', 'https://www.springer.com/journal/10745', 8, True, 'hybrid_open_access'), --79 euro subscription, CC BY 4.0. OA is 'full', so gold.
    ('International Journal of Not-for-Profit Law', 'http://www.icnl.org/research/journal/', 9, False, 'archive'),
    ('Journal of Cleaner Production', 'https://www.journals.elsevier.com/journal-of-cleaner-production', 4, True, 'hybrid_open_access'),
    ('Journal of Law, Economics and Organization', 'https://academic.oup.com/jleo', 10, False, 'hybrid_open_access'), --subscription and single fees
    ('Journal of Political Ecology', 'https://journals.uair.arizona.edu/index.php/JPE', 11, False, 'platinum_open_acess'),
    ('New Political Economy', 'https://www.tandfonline.com/loi/cnpe20', 3, True, 'hybrid_open_access'),
    ('Organization', 'https://journals.sagepub.com/description/ORG', 12, True, 'hybrid_open_access'),
    ('Real World Economics Review', 'http://www.paecon.net/PAEReview/', 13, False, 'platinum_open_acess'),
    ('Sustainability', 'https://www.mdpi.com/journal/sustainability', 14, True, 'gold_open_access'),
    ('Sustainability Science', 'https://www.springer.com/journal/11625', 8, True, 'hybrid_open_access'),
    ('Sustainable Development', 'https://onlinelibrary.wiley.com/journal/10991719', 15, True, 'hybrid_open_access'),
    ('Third World Quaterly', 'https://www.tandfonline.com/loi/ctwq20', 3, True, 'hybrid_open_access'),
    ('Environmental Research Letters', 'https://iopscience.iop.org/journal/1748-9326', 1, False, 'gold_open_access'),
    ('Engaging Science, Technology and Society', 'https://estsjournal.org/index.php/ests', 16, False, 'platinum_open_acess'),
    ('International Journal of Communication', 'https://ijoc.org/index.php/ijoc', 2, False, 'platinum_open_acess');
INSERT INTO fees(journal_id, fee, currency_code, category) VALUES (1, 1400, 'GBP', 'article_processing_charge'), (1, 1600, 'EUR', 'article_processing_charge'), (1, 2100, 'USD', 'article_processing_charge'),
    (2, 3000, 'USD', 'article_processing_charge'),
    (3, 3890, 'EUR', 'article_processing_charge'),
    (4, 1000, 'USD', 'article_processing_charge'),
    (5, 1500, 'GBP', 'article_processing_charge'),
    (6, 3890, 'EUR', 'article_processing_charge'),
    (8, 2170, 'GBP', 'article_processing_charge'), (8, 2750, 'USD', 'article_processing_charge'), (8, 1870, 'GBP', 'article_processing_charge'), (8, 79, 'EUR', 'subscription'),
    (10, 3890, 'EUR', 'article_processing_charge'),
    (11, 2156, 'GBP', 'article_processing_charge'), (11, 3234, 'USD', 'article_processing_charge'), (11, 2628, 'EUR', 'article_processing_charge'), (11, 100, 'USD', 'publication'),
    (13, 3000, 'USD', 'article_processing_charge'),
    (14, 3000, 'USD', 'article_processing_charge'),
    (16, 1500, 'GBP', 'article_processing_charge'), (16, 1700, 'CHF', 'article_processing_charge'),
    (17, 2500, 'GBP', 'article_processing_charge'),
    (18, 3500, 'USD', 'article_processing_charge'),
    (19, 3000, 'USD', 'article_processing_charge'),
    (20, 1800, 'EUR', 'article_processing_charge'), (20, 1500, 'GBP', 'article_processing_charge'), (20, 2080, 'USD', 'article_processing_charge');
INSERT INTO journal_categories(journal_id, category_id) VALUES (1, 1),
    (2, 2),
    (3, 2),
    (4, 3),
    (5, 3),
    (6, 3),
    (7, 3),
    (8, 3),
    (9, 4),
    (10, 3),
    (11, 5), (11, 6),
    (12, 3),
    (13, 6),
    (14, 5),
    (15, 6),
    (16, 3),
    (17, 3),
    (18, 3),
    (19, 7),
    (20, 8),
    (21, 9), (21, 10), (21, 11), (21, 12),
    (22, 13);

-- Institutions
INSERT INTO institutions(name, url) VALUES ('Stockholm University', 'https://www.su.se/');
INSERT INTO institutional_agreements(institution_id, journal_id, agreement, url) VALUES
    (1, 1, 'yes', 'https://www.su.se/english/library/publish/publish-open-access/iop-institute-of-physics-1.398957'),
    (1, 2, 'yes', 'https://www.su.se/english/library/publish/publish-open-access/taylor-francis-1.398924'),
    (1, 7, 'yes', 'https://www.su.se/english/library/publish/publish-open-access/cambridge-university-press-1.419392'),
    (1, 8, 'yes', 'https://www.su.se/english/library/publish/publish-open-access/springer-nature-fully-open-access-journals-1.443030'),
    (1, 11, 'yes', 'https://www.su.se/english/library/publish/publish-open-access/oxford-university-press-1.432712§'),
    (1, 13, 'yes', 'https://www.su.se/english/library/publish/publish-open-access/taylor-francis-1.398924'),
    (1, 17, 'yes', 'https://www.su.se/english/library/publish/publish-open-access/springer-nature-fully-open-access-journals-1.443030'),
    (1, 19, 'yes', 'https://www.su.se/english/library/publish/publish-open-access/taylor-francis-1.398924'),
    (1, 20, 'yes', 'https://www.su.se/english/library/publish/publish-open-access/iop-institute-of-physics-1.398957');
INSERT INTO institutional_agreements(institution_id, journal_id, agreement) VALUES
    (1, 3, 'no'),
    (1, 6, 'no'),
    (1, 9, 'no'),
    (1, 10, 'no'),
    (1, 12, 'not_needed'),
    (1, 14, 'no'),
    (1, 15, 'not_needed'),
    (1, 18, 'no'),
    (1, 21, 'not_needed'),
    (1, 22, 'not_needed');
INSERT INTO institutional_agreements(institution_id, journal_id, agreement, url, details) VALUES (1, 16, 'yes', 'https://www.su.se/english/library/publish/publish-open-access/mdpi-1.398952', '25% Discount'),
    (1, 4, 'not_needed', 'https://www.su.se/english/library/publish/publish-open-access/mdpi-1.398952', 'SU will cover Gold Open Access fees until further notice'),
    (1, 5, 'not_needed', 'https://www.su.se/english/library/publish/publish-open-access/mdpi-1.398952', 'SU will cover Gold Open Access fees until further notice');

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
INSERT INTO publisher_owners(publisher_id, owner_id) VALUES (1, 1), (1, 13),
    (2, 19),
    (3, 11),
    (4, 12),
    (5, 3),
    (6, 14),
    (7, 4),
    (8, 5), (8, 15), (8, 16),
    (9, 6),
    (10, 8),
    (11, 7),
    (12, 17),
    (13, 9),
    (14, 10),
    (15, 15),
    (16, 2);
