-- =============================================================
-- LTH Words — Android SQLite Migration
-- =============================================================

-- ── Schema ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sections (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT    NOT NULL UNIQUE,
    name TEXT    NOT NULL
);

CREATE TABLE IF NOT EXISTS programs (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT    NOT NULL UNIQUE,
    name TEXT    NOT NULL
);

CREATE TABLE IF NOT EXISTS words (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    word TEXT    NOT NULL UNIQUE COLLATE NOCASE
);

CREATE TABLE IF NOT EXISTS word_programs (
    word_id    INTEGER NOT NULL,
    program_id INTEGER NOT NULL,
    PRIMARY KEY (word_id, program_id),
    FOREIGN KEY (word_id)    REFERENCES words(id)    ON DELETE CASCADE,
    FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS dictionary (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id   TEXT    NOT NULL,
    word_id     INTEGER NOT NULL,
    captured_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
    UNIQUE (player_id, word_id),
    FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_dictionary_player
    ON dictionary(player_id);

CREATE INDEX IF NOT EXISTS idx_word_programs_program
    ON word_programs(program_id);

-- ── Seed sections ────────────────────────────────────────────
INSERT OR IGNORE INTO sections (code, name) VALUES ('D', 'D-Section');
INSERT OR IGNORE INTO sections (code, name) VALUES ('K', 'K-Section');
INSERT OR IGNORE INTO sections (code, name) VALUES ('V', 'V-Section');
INSERT OR IGNORE INTO sections (code, name) VALUES ('M', 'M-Section');
INSERT OR IGNORE INTO sections (code, name) VALUES ('E', 'E-Section');
INSERT OR IGNORE INTO sections (code, name) VALUES ('F', 'F-Section');
INSERT OR IGNORE INTO sections (code, name) VALUES ('A', 'A-Section');
INSERT OR IGNORE INTO sections (code, name) VALUES ('W', 'W-Section');
INSERT OR IGNORE INTO sections (code, name) VALUES ('I', 'I-Section');

-- ── Seed programs ────────────────────────────────────────────
INSERT OR IGNORE INTO programs (code, name) VALUES ('A',   'Arkitektur');
INSERT OR IGNORE INTO programs (code, name) VALUES ('B',   'Bioteknik');
INSERT OR IGNORE INTO programs (code, name) VALUES ('BME', 'Medicin och teknik');
INSERT OR IGNORE INTO programs (code, name) VALUES ('BR',  'Brandteknik');
INSERT OR IGNORE INTO programs (code, name) VALUES ('C',   'Informations- och kommunikationsteknik');
INSERT OR IGNORE INTO programs (code, name) VALUES ('D',   'Datateknik');
INSERT OR IGNORE INTO programs (code, name) VALUES ('E',   'Elektroteknik');
INSERT OR IGNORE INTO programs (code, name) VALUES ('F',   'Teknisk fysik');
INSERT OR IGNORE INTO programs (code, name) VALUES ('I',   'Industriell ekonomi');
INSERT OR IGNORE INTO programs (code, name) VALUES ('ID',  'Industridesign');
INSERT OR IGNORE INTO programs (code, name) VALUES ('K',   'Kemiteknik');
INSERT OR IGNORE INTO programs (code, name) VALUES ('L',   'Lantmateri');
INSERT OR IGNORE INTO programs (code, name) VALUES ('M',   'Maskinteknik');
INSERT OR IGNORE INTO programs (code, name) VALUES ('MD',  'Maskinteknik med teknisk design');
INSERT OR IGNORE INTO programs (code, name) VALUES ('N',   'Teknisk nanovetenskap');
INSERT OR IGNORE INTO programs (code, name) VALUES ('Pi',  'Teknisk matematik');
INSERT OR IGNORE INTO programs (code, name) VALUES ('R',   'Risk, sakerhet och krishantering');
INSERT OR IGNORE INTO programs (code, name) VALUES ('V',   'Vag- och vattenbyggnad');
INSERT OR IGNORE INTO programs (code, name) VALUES ('W',   'Ekosystemteknik');

-- ── program_sections table & index ───────────────────────────
CREATE TABLE IF NOT EXISTS program_sections (
    program_id INTEGER NOT NULL,
    section_id INTEGER NOT NULL,
    PRIMARY KEY (program_id, section_id),
    FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE CASCADE,
    FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_program_sections_section
    ON program_sections(section_id);

-- ── Map programs to sections ─────────────────────────────────
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='D'   AND s.code='D';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='C'   AND s.code='D';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='K'   AND s.code='K';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='B'   AND s.code='K';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='V'   AND s.code='V';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='L'   AND s.code='V';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='BR'  AND s.code='V';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='M'   AND s.code='M';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='MD'  AND s.code='M';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='E'   AND s.code='E';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='BME' AND s.code='E';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='F'   AND s.code='F';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='Pi'  AND s.code='F';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='N'   AND s.code='F';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='A'   AND s.code='A';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='ID'  AND s.code='A';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='W'   AND s.code='W';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='R'   AND s.code='W';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='I'   AND s.code='I';

-- ── Seed words ───────────────────────────────────────────────
INSERT OR IGNORE INTO words (word) VALUES ('Anatomy');
INSERT OR IGNORE INTO words (word) VALUES ('Antenna');
INSERT OR IGNORE INTO words (word) VALUES ('API');
INSERT OR IGNORE INTO words (word) VALUES ('Aquifer');
INSERT OR IGNORE INTO words (word) VALUES ('Asphalt');
INSERT OR IGNORE INTO words (word) VALUES ('Bearing');
INSERT OR IGNORE INTO words (word) VALUES ('Bridge');
INSERT OR IGNORE INTO words (word) VALUES ('CAD');
INSERT OR IGNORE INTO words (word) VALUES ('Cache');
INSERT OR IGNORE INTO words (word) VALUES ('Carbon');
INSERT OR IGNORE INTO words (word) VALUES ('Casting');
INSERT OR IGNORE INTO words (word) VALUES ('Cell');
INSERT OR IGNORE INTO words (word) VALUES ('Circuit');
INSERT OR IGNORE INTO words (word) VALUES ('Climate');
INSERT OR IGNORE INTO words (word) VALUES ('Cloud');
INSERT OR IGNORE INTO words (word) VALUES ('Code');
INSERT OR IGNORE INTO words (word) VALUES ('Column');
INSERT OR IGNORE INTO words (word) VALUES ('Concept');
INSERT OR IGNORE INTO words (word) VALUES ('Cost');
INSERT OR IGNORE INTO words (word) VALUES ('Crisis');
INSERT OR IGNORE INTO words (word) VALUES ('Crystal');
INSERT OR IGNORE INTO words (word) VALUES ('Culture');
INSERT OR IGNORE INTO words (word) VALUES ('Dam');
INSERT OR IGNORE INTO words (word) VALUES ('Device');
INSERT OR IGNORE INTO words (word) VALUES ('Diode');
INSERT OR IGNORE INTO words (word) VALUES ('Discrete');
INSERT OR IGNORE INTO words (word) VALUES ('DNA');
INSERT OR IGNORE INTO words (word) VALUES ('Ecology');
INSERT OR IGNORE INTO words (word) VALUES ('Entropy');
INSERT OR IGNORE INTO words (word) VALUES ('Erosion');
INSERT OR IGNORE INTO words (word) VALUES ('Fatigue');
INSERT OR IGNORE INTO words (word) VALUES ('Fiber');
INSERT OR IGNORE INTO words (word) VALUES ('Field');
INSERT OR IGNORE INTO words (word) VALUES ('Filter');
INSERT OR IGNORE INTO words (word) VALUES ('Finance');
INSERT OR IGNORE INTO words (word) VALUES ('Finite');
INSERT OR IGNORE INTO words (word) VALUES ('Flame');
INSERT OR IGNORE INTO words (word) VALUES ('Fluid');
INSERT OR IGNORE INTO words (word) VALUES ('Form');
INSERT OR IGNORE INTO words (word) VALUES ('Fourier');
INSERT OR IGNORE INTO words (word) VALUES ('Friction');
INSERT OR IGNORE INTO words (word) VALUES ('Gear');
INSERT OR IGNORE INTO words (word) VALUES ('Genome');
INSERT OR IGNORE INTO words (word) VALUES ('Geodesy');
INSERT OR IGNORE INTO words (word) VALUES ('GIS');
INSERT OR IGNORE INTO words (word) VALUES ('GPS');
INSERT OR IGNORE INTO words (word) VALUES ('Habitat');
INSERT OR IGNORE INTO words (word) VALUES ('Hazard');
INSERT OR IGNORE INTO words (word) VALUES ('Heat');
INSERT OR IGNORE INTO words (word) VALUES ('Highway');
INSERT OR IGNORE INTO words (word) VALUES ('Implant');
INSERT OR IGNORE INTO words (word) VALUES ('Kernel');
INSERT OR IGNORE INTO words (word) VALUES ('Latency');
INSERT OR IGNORE INTO words (word) VALUES ('Lean');
INSERT OR IGNORE INTO words (word) VALUES ('Lidar');
INSERT OR IGNORE INTO words (word) VALUES ('Linux');
INSERT OR IGNORE INTO words (word) VALUES ('Load');
INSERT OR IGNORE INTO words (word) VALUES ('Matrix');
INSERT OR IGNORE INTO words (word) VALUES ('Memory');
INSERT OR IGNORE INTO words (word) VALUES ('Motor');
INSERT OR IGNORE INTO words (word) VALUES ('MRI');
INSERT OR IGNORE INTO words (word) VALUES ('Network');
INSERT OR IGNORE INTO words (word) VALUES ('Optical');
INSERT OR IGNORE INTO words (word) VALUES ('Packet');
INSERT OR IGNORE INTO words (word) VALUES ('Parcel');
INSERT OR IGNORE INTO words (word) VALUES ('Particle');
INSERT OR IGNORE INTO words (word) VALUES ('Phase');
INSERT OR IGNORE INTO words (word) VALUES ('Photon');
INSERT OR IGNORE INTO words (word) VALUES ('Pipe');
INSERT OR IGNORE INTO words (word) VALUES ('Plasma');
INSERT OR IGNORE INTO words (word) VALUES ('Plasmid');
INSERT OR IGNORE INTO words (word) VALUES ('Polymer');
INSERT OR IGNORE INTO words (word) VALUES ('Power');
INSERT OR IGNORE INTO words (word) VALUES ('Process');
INSERT OR IGNORE INTO words (word) VALUES ('Product');
INSERT OR IGNORE INTO words (word) VALUES ('Project');
INSERT OR IGNORE INTO words (word) VALUES ('Proof');
INSERT OR IGNORE INTO words (word) VALUES ('Protein');
INSERT OR IGNORE INTO words (word) VALUES ('Pump');
INSERT OR IGNORE INTO words (word) VALUES ('Quality');
INSERT OR IGNORE INTO words (word) VALUES ('Quantum');
INSERT OR IGNORE INTO words (word) VALUES ('Reactor');
INSERT OR IGNORE INTO words (word) VALUES ('Relay');
INSERT OR IGNORE INTO words (word) VALUES ('Risk');
INSERT OR IGNORE INTO words (word) VALUES ('Routing');
INSERT OR IGNORE INTO words (word) VALUES ('Safety');
INSERT OR IGNORE INTO words (word) VALUES ('Scale');
INSERT OR IGNORE INTO words (word) VALUES ('Sensor');
INSERT OR IGNORE INTO words (word) VALUES ('Series');
INSERT OR IGNORE INTO words (word) VALUES ('Shaft');
INSERT OR IGNORE INTO words (word) VALUES ('Signal');
INSERT OR IGNORE INTO words (word) VALUES ('Slurry');
INSERT OR IGNORE INTO words (word) VALUES ('Smoke');
INSERT OR IGNORE INTO words (word) VALUES ('Soil');
INSERT OR IGNORE INTO words (word) VALUES ('Solvent');
INSERT OR IGNORE INTO words (word) VALUES ('Species');
INSERT OR IGNORE INTO words (word) VALUES ('Spectrum');
INSERT OR IGNORE INTO words (word) VALUES ('Stress');
INSERT OR IGNORE INTO words (word) VALUES ('Tensor');
INSERT OR IGNORE INTO words (word) VALUES ('Theorem');
INSERT OR IGNORE INTO words (word) VALUES ('Therapy');
INSERT OR IGNORE INTO words (word) VALUES ('Thermal');
INSERT OR IGNORE INTO words (word) VALUES ('Threat');
INSERT OR IGNORE INTO words (word) VALUES ('Tissue');
INSERT OR IGNORE INTO words (word) VALUES ('Torque');
INSERT OR IGNORE INTO words (word) VALUES ('Traffic');
INSERT OR IGNORE INTO words (word) VALUES ('Tunnel');
INSERT OR IGNORE INTO words (word) VALUES ('Voltage');
INSERT OR IGNORE INTO words (word) VALUES ('Wave');
INSERT OR IGNORE INTO words (word) VALUES ('Wetland');
INSERT OR IGNORE INTO words (word) VALUES ('Yield');
INSERT OR IGNORE INTO words (word) VALUES ('Zoning');
INSERT OR IGNORE INTO words (word) VALUES ('Arch');
INSERT OR IGNORE INTO words (word) VALUES ('Draft');
INSERT OR IGNORE INTO words (word) VALUES ('Facade');
INSERT OR IGNORE INTO words (word) VALUES ('Model');
INSERT OR IGNORE INTO words (word) VALUES ('Plan');
INSERT OR IGNORE INTO words (word) VALUES ('Sketch');
INSERT OR IGNORE INTO words (word) VALUES ('Space');
INSERT OR IGNORE INTO words (word) VALUES ('Style');
INSERT OR IGNORE INTO words (word) VALUES ('Urban');
INSERT OR IGNORE INTO words (word) VALUES ('Color');
INSERT OR IGNORE INTO words (word) VALUES ('Curve');
INSERT OR IGNORE INTO words (word) VALUES ('Design');
INSERT OR IGNORE INTO words (word) VALUES ('Ergon');
INSERT OR IGNORE INTO words (word) VALUES ('Foam');
INSERT OR IGNORE INTO words (word) VALUES ('Shape');

-- ── word_programs ─────────────────────────────────────────────
-- A — Arkitektur
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Arch'         AND p.code='A';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Draft'        AND p.code='A';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Facade'       AND p.code='A';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Model'        AND p.code='A';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Plan'         AND p.code='A';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Sketch'       AND p.code='A';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Space'        AND p.code='A';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Style'        AND p.code='A';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Urban'        AND p.code='A';
-- B — Bioteknik
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='DNA'          AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Genome'       AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Plasmid'      AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Culture'      AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Tissue'       AND p.code='B';
-- B shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Cell'         AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Protein'      AND p.code='B';

-- BR — Brandteknik
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Smoke'        AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Heat'         AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Flame'        AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Code'         AND p.code='BR';
-- BR shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Risk'         AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Safety'       AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Sensor'       AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Thermal'      AND p.code='BR';

-- C — Informations- och kommunikationsteknik
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Fiber'        AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Latency'      AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Spectrum'     AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Packet'       AND p.code='C';
-- C shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Antenna'      AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Cloud'        AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Network'      AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Signal'       AND p.code='C';

-- D — Datateknik
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Cache'        AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Linux'        AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Memory'       AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Kernel'       AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='API'          AND p.code='D';
-- D shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Cloud'        AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Network'      AND p.code='D';

-- E — Elektroteknik
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Circuit'      AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Voltage'      AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Filter'       AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Relay'        AND p.code='E';
-- E shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Antenna'      AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Diode'        AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Motor'        AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Power'        AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Sensor'       AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Signal'       AND p.code='E';

-- F — Teknisk fysik
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Wave'         AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Particle'     AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Plasma'       AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Tensor'       AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Field'        AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Entropy'      AND p.code='F';
-- F shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Finite'       AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Optical'      AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Photon'       AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Quantum'      AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Thermal'      AND p.code='F';

-- I — Industriell ekonomi
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Finance'      AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Lean'         AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Cost'         AND p.code='I';
-- I shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Process'      AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Project'      AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Quality'      AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Risk'         AND p.code='I';

-- ID — Industridesign
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Color'        AND p.code='ID';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Curve'        AND p.code='ID';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Design'       AND p.code='ID';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Ergon'        AND p.code='ID';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Foam'         AND p.code='ID';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Model'        AND p.code='ID';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Shape'        AND p.code='ID';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Sketch'       AND p.code='ID';
-- K — Kemiteknik
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Reactor'      AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Solvent'      AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Polymer'      AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Phase'        AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Yield'        AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Slurry'       AND p.code='K';
-- K shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Fluid'        AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Process'      AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Thermal'      AND p.code='K';

-- L — Lantmäteri
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Geodesy'      AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='GPS'          AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Lidar'        AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Scale'        AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Parcel'       AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Zoning'       AND p.code='L';
-- L shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='GIS'          AND p.code='L';

-- M — Maskinteknik
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Fatigue'      AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Gear'         AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Torque'       AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Casting'      AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Friction'     AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Shaft'        AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Pump'         AND p.code='M';
-- M shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='CAD'          AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Finite'       AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Fluid'        AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Motor'        AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Power'        AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Project'      AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Quality'      AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Stress'       AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Thermal'      AND p.code='M';

-- MD — Maskinteknik med teknisk design
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Concept'      AND p.code='MD';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Form'         AND p.code='MD';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Product'      AND p.code='MD';
-- MD shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='CAD'          AND p.code='MD';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Stress'       AND p.code='MD';

-- BME — Medicin och teknik
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Implant'      AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Anatomy'      AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='MRI'          AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Therapy'      AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Device'       AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Tissue'       AND p.code='BME';
-- BME shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Cell'         AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Protein'      AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Sensor'       AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Signal'       AND p.code='BME';

-- N — Teknisk nanovetenskap
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Crystal'      AND p.code='N';
-- N shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Diode'        AND p.code='N';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Optical'      AND p.code='N';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Photon'       AND p.code='N';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Quantum'      AND p.code='N';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Sensor'       AND p.code='N';

-- Pi — Teknisk matematik
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Matrix'       AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Fourier'      AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Proof'        AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Discrete'     AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Theorem'      AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Series'       AND p.code='Pi';
-- Pi shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Finite'       AND p.code='Pi';

-- R — Risk, säkerhet och krishantering
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Threat'       AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Crisis'       AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Hazard'       AND p.code='R';
-- R shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Risk'         AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Safety'       AND p.code='R';

-- V — Väg- och vattenbyggnad
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Bridge'       AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Asphalt'      AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Dam'          AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Traffic'      AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Tunnel'       AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Load'         AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Highway'      AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Column'       AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Pipe'         AND p.code='V';
-- V shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Soil'         AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Stress'       AND p.code='V';

-- W — Ekosystemteknik
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Ecology'      AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Carbon'       AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Species'      AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Wetland'      AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Climate'      AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Habitat'      AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Erosion'      AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Aquifer'      AND p.code='W';
-- W shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='GIS'          AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Soil'         AND p.code='W';