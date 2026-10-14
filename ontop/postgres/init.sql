-- Demo relational data for the Ontop virtual knowledge graph. Same facts as data/sample, as tables.
CREATE TABLE category (
    slug text PRIMARY KEY,
    name text NOT NULL
);

CREATE TABLE service (
    slug        text PRIMARY KEY,
    name        text NOT NULL,
    description text,
    port        integer,
    language    text,
    category    text NOT NULL REFERENCES category (slug)
);

CREATE TABLE dependency (
    service    text NOT NULL REFERENCES service (slug),
    depends_on text NOT NULL REFERENCES service (slug),
    PRIMARY KEY (service, depends_on)
);

INSERT INTO category VALUES
    ('triple-store',  'Triple store'),
    ('transformation','Data transformation'),
    ('visualisation', 'Visualisation and browsing'),
    ('query',         'Query tooling'),
    ('virtualisation','Virtual knowledge graphs');

INSERT INTO service VALUES
    ('qlever',    'QLever',             'Very fast SPARQL engine for large, read-mostly graphs.', 7001, 'C++',        'triple-store'),
    ('fuseki',    'Apache Jena Fuseki', 'General-purpose SPARQL server.',                         3030, 'Java',       'triple-store'),
    ('oxigraph',  'Oxigraph',           'Lightweight Rust store with no setup step.',             7878, 'Rust',       'triple-store'),
    ('rdf4j',     'RDF4J Workbench',    'Repository manager and query UI.',                       8082, 'Java',       'query'),
    ('openrefine','OpenRefine',         'Interactive data cleaning and reconciliation.',          3333, 'Java',       'transformation'),
    ('trifid',    'Trifid',             'Linked Data frontend.',                                  8084, 'JavaScript', 'visualisation'),
    ('blueprint', 'Blueprint',          'Knowledge-graph browser.',                               8085, 'TypeScript', 'visualisation'),
    ('comunica',  'Comunica',           'Federated SPARQL endpoint.',                             8087, 'TypeScript', 'query'),
    ('ontop',     'Ontop',              'Virtual knowledge graph over a relational database.',    8089, 'Java',       'virtualisation');

INSERT INTO dependency VALUES
    ('trifid',    'qlever'),
    ('blueprint', 'trifid'),
    ('comunica',  'qlever'),
    ('comunica',  'fuseki');
