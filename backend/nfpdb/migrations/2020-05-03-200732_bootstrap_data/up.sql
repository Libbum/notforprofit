CREATE TYPE reach AS ENUM ('local', 'state', 'national', 'international');

CREATE TABLE sectors (
    id INT UNIQUE NOT NULL PRIMARY KEY,
    description TEXT
);

CREATE TABLE countries (
    id VARCHAR NOT NULL PRIMARY KEY CHECK (length(id) = 2),
    name VARCHAR NOT NULL
);

CREATE TABLE addresses (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    line1 VARCHAR NOT NULL,
    line2 VARCHAR,
    line3 VARCHAR,
    city VARCHAR,
    state_province VARCHAR,
    postal_code VARCHAR,
    country_id VARCHAR NOT NULL CHECK (length(country_id) = 2),
    location point,
    other_details VARCHAR,
    FOREIGN KEY (country_id) REFERENCES countries(id)
);

CREATE TABLE businesses (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR NOT NULL,
    sector_id INT NOT NULL,
    scale reach NOT NULL,
    address_id INT NOT NULL,
    url TEXT,
    notes TEXT,
    FOREIGN KEY (sector_id) REFERENCES sectors(id),
    FOREIGN KEY (address_id) REFERENCES addresses(id)
);

INSERT INTO sectors(id, description) VALUES
    (11, 'Agriculture, Forestry, Fishing and Hunting'),
    (21, 'Mining, Quarrying, and Oil and Gas Extraction'),
    (22, 'Utilities'),
    (23, 'Construction'),
    (31, 'Manufacturing'),
    (32, 'Manufacturing'),
    (33, 'Manufacturing'),
    (42, 'Wholesale Trade'),
    (44, 'Retail Trade'),
    (45, 'Retail Trade'),
    (48, 'Transportation and Warehousing'),
    (49, 'Transportation and Warehousing'),
    (51, 'Information'),
    (52, 'Finance and Insurance'),
    (53, 'Real Estate and Rental and Leasing'),
    (54, 'Professional, Scientific, and Technical Services'),
    (55, 'Management of Companies and Enterprises'),
    (56, 'Administrative and Support and Waste Management and Remediation Services'),
    (61, 'Educational Services'),
    (62, 'Health Care and Social Assistance'),
    (71, 'Arts, Entertainment, and Recreation'),
    (72, 'Accommodation and Food Services'),
    (81, 'Other Services (except Public Administration)'),
    (92, 'Public Administration');


INSERT INTO countries(id, name) VALUES
    ('AF', 'Afghanistan'),
    ('AX', 'Åland Islands'),
    ('AL', 'Albania'),
    ('DZ', 'Algeria'),
    ('AS', 'American Samoa'),
    ('AD', 'Andorra'),
    ('AO', 'Angola'),
    ('AI', 'Anguilla'),
    ('AQ', 'Antarctica'),
    ('AG', 'Antigua & Barbuda'),
    ('AR', 'Argentina'),
    ('AM', 'Armenia'),
    ('AW', 'Aruba'),
    ('AC', 'Ascension Island'),
    ('AU', 'Australia'),
    ('AT', 'Austria'),
    ('AZ', 'Azerbaijan'),
    ('BS', 'Bahamas'),
    ('BH', 'Bahrain'),
    ('BD', 'Bangladesh'),
    ('BB', 'Barbados'),
    ('BY', 'Belarus'),
    ('BE', 'Belgium'),
    ('BZ', 'Belize'),
    ('BJ', 'Benin'),
    ('BM', 'Bermuda'),
    ('BT', 'Bhutan'),
    ('BO', 'Bolivia'),
    ('BA', 'Bosnia & Herzegovina'),
    ('BW', 'Botswana'),
    ('BR', 'Brazil'),
    ('IO', 'British Indian Ocean Territory'),
    ('VG', 'British Virgin Islands'),
    ('BN', 'Brunei'),
    ('BG', 'Bulgaria'),
    ('BF', 'Burkina Faso'),
    ('BI', 'Burundi'),
    ('KH', 'Cambodia'),
    ('CM', 'Cameroon'),
    ('CA', 'Canada'),
    ('IC', 'Canary Islands'),
    ('CV', 'Cape Verde'),
    ('BQ', 'Caribbean Netherlands'),
    ('KY', 'Cayman Islands'),
    ('CF', 'Central African Republic'),
    ('EA', 'Ceuta & Melilla'),
    ('TD', 'Chad'),
    ('CL', 'Chile'),
    ('CN', 'China'),
    ('CX', 'Christmas Island'),
    ('CC', 'Cocos (Keeling) Islands'),
    ('CO', 'Colombia'),
    ('KM', 'Comoros'),
    ('CG', 'Congo - Brazzaville'),
    ('CD', 'Congo - Kinshasa'),
    ('CK', 'Cook Islands'),
    ('CR', 'Costa Rica'),
    ('CI', 'Côte d’Ivoire'),
    ('HR', 'Croatia'),
    ('CU', 'Cuba'),
    ('CW', 'Curaçao'),
    ('CY', 'Cyprus'),
    ('CZ', 'Czechia'),
    ('DK', 'Denmark'),
    ('DG', 'Diego Garcia'),
    ('DJ', 'Djibouti'),
    ('DM', 'Dominica'),
    ('DO', 'Dominican Republic'),
    ('EC', 'Ecuador'),
    ('EG', 'Egypt'),
    ('SV', 'El Salvador'),
    ('GQ', 'Equatorial Guinea'),
    ('ER', 'Eritrea'),
    ('EE', 'Estonia'),
    ('SZ', 'Eswatini'),
    ('ET', 'Ethiopia'),
    ('FK', 'Falkland Islands'),
    ('FO', 'Faroe Islands'),
    ('FJ', 'Fiji'),
    ('FI', 'Finland'),
    ('FR', 'France'),
    ('GF', 'French Guiana'),
    ('PF', 'French Polynesia'),
    ('TF', 'French Southern Territories'),
    ('GA', 'Gabon'),
    ('GM', 'Gambia'),
    ('GE', 'Georgia'),
    ('DE', 'Germany'),
    ('GH', 'Ghana'),
    ('GI', 'Gibraltar'),
    ('GR', 'Greece'),
    ('GL', 'Greenland'),
    ('GD', 'Grenada'),
    ('GP', 'Guadeloupe'),
    ('GU', 'Guam'),
    ('GT', 'Guatemala'),
    ('GG', 'Guernsey'),
    ('GN', 'Guinea'),
    ('GW', 'Guinea-Bissau'),
    ('GY', 'Guyana'),
    ('HT', 'Haiti'),
    ('HN', 'Honduras'),
    ('HK', 'Hong Kong SAR China'),
    ('HU', 'Hungary'),
    ('IS', 'Iceland'),
    ('IN', 'India'),
    ('ID', 'Indonesia'),
    ('IR', 'Iran'),
    ('IQ', 'Iraq'),
    ('IE', 'Ireland'),
    ('IM', 'Isle of Man'),
    ('IL', 'Israel'),
    ('IT', 'Italy'),
    ('JM', 'Jamaica'),
    ('JP', 'Japan'),
    ('JE', 'Jersey'),
    ('JO', 'Jordan'),
    ('KZ', 'Kazakhstan'),
    ('KE', 'Kenya'),
    ('KI', 'Kiribati'),
    ('XK', 'Kosovo'),
    ('KW', 'Kuwait'),
    ('KG', 'Kyrgyzstan'),
    ('LA', 'Laos'),
    ('LV', 'Latvia'),
    ('LB', 'Lebanon'),
    ('LS', 'Lesotho'),
    ('LR', 'Liberia'),
    ('LY', 'Libya'),
    ('LI', 'Liechtenstein'),
    ('LT', 'Lithuania'),
    ('LU', 'Luxembourg'),
    ('MO', 'Macao SAR China'),
    ('MG', 'Madagascar'),
    ('MW', 'Malawi'),
    ('MY', 'Malaysia'),
    ('MV', 'Maldives'),
    ('ML', 'Mali'),
    ('MT', 'Malta'),
    ('MH', 'Marshall Islands'),
    ('MQ', 'Martinique'),
    ('MR', 'Mauritania'),
    ('MU', 'Mauritius'),
    ('YT', 'Mayotte'),
    ('MX', 'Mexico'),
    ('FM', 'Micronesia'),
    ('MD', 'Moldova'),
    ('MC', 'Monaco'),
    ('MN', 'Mongolia'),
    ('ME', 'Montenegro'),
    ('MS', 'Montserrat'),
    ('MA', 'Morocco'),
    ('MZ', 'Mozambique'),
    ('MM', 'Myanmar (Burma)'),
    ('NA', 'Namibia'),
    ('NR', 'Nauru'),
    ('NP', 'Nepal'),
    ('NL', 'Netherlands'),
    ('NC', 'New Caledonia'),
    ('NZ', 'New Zealand'),
    ('NI', 'Nicaragua'),
    ('NE', 'Niger'),
    ('NG', 'Nigeria'),
    ('NU', 'Niue'),
    ('NF', 'Norfolk Island'),
    ('KP', 'North Korea'),
    ('MK', 'North Macedonia'),
    ('MP', 'Northern Mariana Islands'),
    ('NO', 'Norway'),
    ('OM', 'Oman'),
    ('PK', 'Pakistan'),
    ('PW', 'Palau'),
    ('PS', 'Palestinian Territories'),
    ('PA', 'Panama'),
    ('PG', 'Papua New Guinea'),
    ('PY', 'Paraguay'),
    ('PE', 'Peru'),
    ('PH', 'Philippines'),
    ('PN', 'Pitcairn Islands'),
    ('PL', 'Poland'),
    ('PT', 'Portugal'),
    ('XA', 'Pseudo-Accents'),
    ('XB', 'Pseudo-Bidi'),
    ('PR', 'Puerto Rico'),
    ('QA', 'Qatar'),
    ('RE', 'Réunion'),
    ('RO', 'Romania'),
    ('RU', 'Russia'),
    ('RW', 'Rwanda'),
    ('WS', 'Samoa'),
    ('SM', 'San Marino'),
    ('ST', 'São Tomé & Príncipe'),
    ('SA', 'Saudi Arabia'),
    ('SN', 'Senegal'),
    ('RS', 'Serbia'),
    ('SC', 'Seychelles'),
    ('SL', 'Sierra Leone'),
    ('SG', 'Singapore'),
    ('SX', 'Sint Maarten'),
    ('SK', 'Slovakia'),
    ('SI', 'Slovenia'),
    ('SB', 'Solomon Islands'),
    ('SO', 'Somalia'),
    ('ZA', 'South Africa'),
    ('GS', 'South Georgia & South Sandwich Islands'),
    ('KR', 'South Korea'),
    ('SS', 'South Sudan'),
    ('ES', 'Spain'),
    ('LK', 'Sri Lanka'),
    ('BL', 'St. Barthélemy'),
    ('SH', 'St. Helena'),
    ('KN', 'St. Kitts & Nevis'),
    ('LC', 'St. Lucia'),
    ('MF', 'St. Martin'),
    ('PM', 'St. Pierre & Miquelon'),
    ('VC', 'St. Vincent & Grenadines'),
    ('SD', 'Sudan'),
    ('SR', 'Suriname'),
    ('SJ', 'Svalbard & Jan Mayen'),
    ('SE', 'Sweden'),
    ('CH', 'Switzerland'),
    ('SY', 'Syria'),
    ('TW', 'Taiwan'),
    ('TJ', 'Tajikistan'),
    ('TZ', 'Tanzania'),
    ('TH', 'Thailand'),
    ('TL', 'Timor-Leste'),
    ('TG', 'Togo'),
    ('TK', 'Tokelau'),
    ('TO', 'Tonga'),
    ('TT', 'Trinidad & Tobago'),
    ('TA', 'Tristan da Cunha'),
    ('TN', 'Tunisia'),
    ('TR', 'Turkey'),
    ('TM', 'Turkmenistan'),
    ('TC', 'Turks & Caicos Islands'),
    ('TV', 'Tuvalu'),
    ('UM', 'U.S. Outlying Islands'),
    ('VI', 'U.S. Virgin Islands'),
    ('UG', 'Uganda'),
    ('UA', 'Ukraine'),
    ('AE', 'United Arab Emirates'),
    ('GB', 'United Kingdom'),
    ('US', 'United States'),
    ('UY', 'Uruguay'),
    ('UZ', 'Uzbekistan'),
    ('VU', 'Vanuatu'),
    ('VA', 'Vatican City'),
    ('VE', 'Venezuela'),
    ('VN', 'Vietnam'),
    ('WF', 'Wallis & Futuna'),
    ('EH', 'Western Sahara'),
    ('YE', 'Yemen'),
    ('ZM', 'Zambia'),
    ('ZW', 'Zimbabwe');

INSERT INTO addresses(line1, city, state_province, postal_code, country_id, location) VALUES
    ('605 Hovell Street', 'South Albury', 'NSW', '2640', 'AU', point(-36.086554, 146.910483));

INSERT INTO businesses(name, sector_id, scale, address_id, url, notes) VALUES
    ('Flying Fruit Fly', 62, 'national', 1, 'http://fruitflycircus.com.au/', 'Australia''s only full time circus training institution for children.  It’s a not-for-profit company that for 30 years has played an important role in the development of contemporary circus in Australia.');

