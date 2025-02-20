CREATE TABLE mtg_card (
    id TEXT PRIMARY KEY,
    arena_id INTEGER,
    lang TEXT,
    mtgo_id INTEGER,
    mtgo_foil_id INTEGER,
    tcgplayer_id INTEGER,
    tcgplayer_etched_id INTEGER,
    cardmarket_id INTEGER,
    oracle_id TEXT,
    prints_search_uri TEXT,
    rulings_uri TEXT,
    scryfall_uri TEXT,
    uri TEXT,
    cmc REAL,
    edhrec_rank INTEGER,
    hand_modifier TEXT,
    life_modifier TEXT,
    loyalty TEXT,
    mana_cost TEXT,
    name TEXT NOT NULL,
    oracle_text TEXT,
    oversized INTEGER NOT NULL CHECK (oversized IN (0,1)),
    power TEXT,
    reserved INTEGER NOT NULL CHECK (reserved IN (0,1)),
    toughness TEXT,
    type_line TEXT NOT NULL,
    artist TEXT,
    booster INTEGER NOT NULL CHECK (booster IN (0,1)),
    border_color TEXT,
    card_back_id TEXT,
    collector_number TEXT NOT NULL,
    content_warning INTEGER CHECK (content_warning IN (0,1)),
    digital INTEGER NOT NULL CHECK (digital IN (0,1)),
    foil INTEGER NOT NULL CHECK (foil IN (0,1)),
    nonfoil INTEGER NOT NULL CHECK (nonfoil IN (0,1)),
    frame TEXT,
    full_art INTEGER NOT NULL CHECK (full_art IN (0,1)),
    highres_image INTEGER NOT NULL CHECK (highres_image IN (0,1)),
    illustration_id TEXT,
    image_status TEXT,
    promo INTEGER NOT NULL CHECK (promo IN (0,1)),
    rarity TEXT NOT NULL,
    released_at TEXT NOT NULL,
    reprint INTEGER NOT NULL CHECK (reprint IN (0,1)),
    scryfall_set_uri TEXT NOT NULL,
    set_name TEXT NOT NULL,
    set_search_uri TEXT NOT NULL,
    set_type TEXT NOT NULL,
    set_uri TEXT NOT NULL,
    set_code TEXT NOT NULL,
    set_id TEXT NOT NULL,
    story_spotlight INTEGER NOT NULL CHECK (story_spotlight IN (0,1)),
    textless INTEGER NOT NULL CHECK (textless IN (0,1)),
    variation INTEGER NOT NULL CHECK (variation IN (0,1)),
    variation_of TEXT,
    watermark TEXT
);