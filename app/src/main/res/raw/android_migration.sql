-- =============================================================
-- LTH Words — Android SQLite Migration
-- Compatible with Room (as a @RawQuery asset) and
-- SQLiteOpenHelper (call in onCreate / onUpgrade).
--
-- Android does NOT enable foreign keys by default.
-- With Room: add @Database(foreignKeyConstraints = true)
-- With SQLiteOpenHelper: call db.execSQL("PRAGMA foreign_keys = ON;")
--   in your onOpen() override.
-- =============================================================

-- ── Schema ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sections (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT    NOT NULL UNIQUE,
    name TEXT    NOT NULL
);

CREATE TABLE IF NOT EXISTS program_sections (
    program_id INTEGER NOT NULL,
    section_id INTEGER NOT NULL,
    PRIMARY KEY (program_id, section_id),
    FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE CASCADE,
    FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE
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

-- dictionary: one row per (player, word) pair.
-- Capturing a shared word once automatically covers all its programmes
-- because you join through word_programs in your queries.
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

CREATE INDEX IF NOT EXISTS idx_program_sections_section
    ON program_sections(section_id);

-- Seed sections
INSERT OR IGNORE INTO sections (code, name) VALUES ('D', 'Datateknik och Informations- och kommunikationsteknik');
INSERT OR IGNORE INTO sections (code, name) VALUES ('K', 'Kemiteknik, Bioteknik och kandidatprogrammet i livsmedelsteknik');
INSERT OR IGNORE INTO sections (code, name) VALUES ('V', 'Väg- och Vattenbyggnad, Lantmäteri, Brandingenjör, Riskhantering');
INSERT OR IGNORE INTO sections (code, name) VALUES ('M', 'Maskinteknik och Maskinteknik med teknisk design');
INSERT OR IGNORE INTO sections (code, name) VALUES ('E', 'Elektroteknik och Medicin och Teknik');
INSERT OR IGNORE INTO sections (code, name) VALUES ('F', 'Teknisk Fysik, Teknisk Matematik och Teknisk Nanovetenskap');
-- Map programs to sections
-- D section: D, C
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='D' AND s.code='D';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='C' AND s.code='D';
-- K section: K, B
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='K' AND s.code='K';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='B' AND s.code='K';
-- V section: V, L, BR, R
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='V'  AND s.code='V';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='L'  AND s.code='V';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='BR' AND s.code='V';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='R'  AND s.code='V';
-- M section: M, MD
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='M'  AND s.code='M';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='MD' AND s.code='M';
-- E section: E, BME
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='E'   AND s.code='E';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='BME' AND s.code='E';
-- F section: F, Pi, N
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='F'  AND s.code='F';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='Pi' AND s.code='F';
INSERT OR IGNORE INTO program_sections SELECT p.id, s.id FROM programs p, sections s WHERE p.code='N'  AND s.code='F';
-- ── Seed data ────────────────────────────────────────────────
-- programmes
INSERT OR IGNORE INTO programs (code, name) VALUES ('B',   'Bioteknik');
INSERT OR IGNORE INTO programs (code, name) VALUES ('BME', 'Medicin och teknik');
INSERT OR IGNORE INTO programs (code, name) VALUES ('BR',  'Brandteknik');
INSERT OR IGNORE INTO programs (code, name) VALUES ('C',   'Informations- och kommunikationsteknik');
INSERT OR IGNORE INTO programs (code, name) VALUES ('D',   'Datateknik');
INSERT OR IGNORE INTO programs (code, name) VALUES ('E',   'Elektroteknik');
INSERT OR IGNORE INTO programs (code, name) VALUES ('F',   'Teknisk fysik');
INSERT OR IGNORE INTO programs (code, name) VALUES ('I',   'Industriell ekonomi');
INSERT OR IGNORE INTO programs (code, name) VALUES ('K',   'Kemiteknik');
INSERT OR IGNORE INTO programs (code, name) VALUES ('L',   'Lantmateri');
INSERT OR IGNORE INTO programs (code, name) VALUES ('M',   'Maskinteknik');
INSERT OR IGNORE INTO programs (code, name) VALUES ('MD',  'Maskinteknik med teknisk design');
INSERT OR IGNORE INTO programs (code, name) VALUES ('N',   'Teknisk nanovetenskap');
INSERT OR IGNORE INTO programs (code, name) VALUES ('Pi',  'Teknisk matematik');
INSERT OR IGNORE INTO programs (code, name) VALUES ('R',   'Risk, sakerhet och krishantering');
INSERT OR IGNORE INTO programs (code, name) VALUES ('V',   'Vag- och vattenbyggnad');
INSERT OR IGNORE INTO programs (code, name) VALUES ('W',   'Ekosystemteknik');

-- ── words (unique set) ───────────────────────────────────────
INSERT OR IGNORE INTO words (word) VALUES ('Absorption');
INSERT OR IGNORE INTO words (word) VALUES ('Accounting');
INSERT OR IGNORE INTO words (word) VALUES ('Algorithm');
INSERT OR IGNORE INTO words (word) VALUES ('Amplifier');
INSERT OR IGNORE INTO words (word) VALUES ('Anatomy');
INSERT OR IGNORE INTO words (word) VALUES ('Antenna');
INSERT OR IGNORE INTO words (word) VALUES ('Antibody');
INSERT OR IGNORE INTO words (word) VALUES ('API');
INSERT OR IGNORE INTO words (word) VALUES ('Approximation');
INSERT OR IGNORE INTO words (word) VALUES ('Aquifer');
INSERT OR IGNORE INTO words (word) VALUES ('Architecture');
INSERT OR IGNORE INTO words (word) VALUES ('Assessment');
INSERT OR IGNORE INTO words (word) VALUES ('Assembly');
INSERT OR IGNORE INTO words (word) VALUES ('Asphalt');
INSERT OR IGNORE INTO words (word) VALUES ('Aesthetics');
INSERT OR IGNORE INTO words (word) VALUES ('Authentication');
INSERT OR IGNORE INTO words (word) VALUES ('Bandwidth');
INSERT OR IGNORE INTO words (word) VALUES ('Bearing');
INSERT OR IGNORE INTO words (word) VALUES ('Biodiversity');
INSERT OR IGNORE INTO words (word) VALUES ('Biocompatibility');
INSERT OR IGNORE INTO words (word) VALUES ('Biogeochemistry');
INSERT OR IGNORE INTO words (word) VALUES ('Biomaterials');
INSERT OR IGNORE INTO words (word) VALUES ('Biomechanics');
INSERT OR IGNORE INTO words (word) VALUES ('Bioprocess');
INSERT OR IGNORE INTO words (word) VALUES ('Bioreactor');
INSERT OR IGNORE INTO words (word) VALUES ('Boundary');
INSERT OR IGNORE INTO words (word) VALUES ('Bridge');
INSERT OR IGNORE INTO words (word) VALUES ('Building');
INSERT OR IGNORE INTO words (word) VALUES ('Business');
INSERT OR IGNORE INTO words (word) VALUES ('CAD');
INSERT OR IGNORE INTO words (word) VALUES ('Cache');
INSERT OR IGNORE INTO words (word) VALUES ('Capacitor');
INSERT OR IGNORE INTO words (word) VALUES ('Carbon');
INSERT OR IGNORE INTO words (word) VALUES ('Casting');
INSERT OR IGNORE INTO words (word) VALUES ('Catalyst');
INSERT OR IGNORE INTO words (word) VALUES ('Cell');
INSERT OR IGNORE INTO words (word) VALUES ('Chromatography');
INSERT OR IGNORE INTO words (word) VALUES ('Circuit');
INSERT OR IGNORE INTO words (word) VALUES ('Climate');
INSERT OR IGNORE INTO words (word) VALUES ('Clinical');
INSERT OR IGNORE INTO words (word) VALUES ('Cloning');
INSERT OR IGNORE INTO words (word) VALUES ('Cloud');
INSERT OR IGNORE INTO words (word) VALUES ('Code');
INSERT OR IGNORE INTO words (word) VALUES ('Coding');
INSERT OR IGNORE INTO words (word) VALUES ('Column');
INSERT OR IGNORE INTO words (word) VALUES ('Combustion');
INSERT OR IGNORE INTO words (word) VALUES ('Communication');
INSERT OR IGNORE INTO words (word) VALUES ('Compiler');
INSERT OR IGNORE INTO words (word) VALUES ('Compression');
INSERT OR IGNORE INTO words (word) VALUES ('Compressor');
INSERT OR IGNORE INTO words (word) VALUES ('Computation');
INSERT OR IGNORE INTO words (word) VALUES ('Concept');
INSERT OR IGNORE INTO words (word) VALUES ('Concrete');
INSERT OR IGNORE INTO words (word) VALUES ('Conductor');
INSERT OR IGNORE INTO words (word) VALUES ('Conservation');
INSERT OR IGNORE INTO words (word) VALUES ('Construction');
INSERT OR IGNORE INTO words (word) VALUES ('Continuity');
INSERT OR IGNORE INTO words (word) VALUES ('Convergence');
INSERT OR IGNORE INTO words (word) VALUES ('Coordinate');
INSERT OR IGNORE INTO words (word) VALUES ('Coordination');
INSERT OR IGNORE INTO words (word) VALUES ('Corrosion');
INSERT OR IGNORE INTO words (word) VALUES ('Cost');
INSERT OR IGNORE INTO words (word) VALUES ('Crisis');
INSERT OR IGNORE INTO words (word) VALUES ('Crystal');
INSERT OR IGNORE INTO words (word) VALUES ('Cryptography');
INSERT OR IGNORE INTO words (word) VALUES ('Culture');
INSERT OR IGNORE INTO words (word) VALUES ('Cybersecurity');
INSERT OR IGNORE INTO words (word) VALUES ('Dam');
INSERT OR IGNORE INTO words (word) VALUES ('Database');
INSERT OR IGNORE INTO words (word) VALUES ('Debugging');
INSERT OR IGNORE INTO words (word) VALUES ('Decision');
INSERT OR IGNORE INTO words (word) VALUES ('Delineation');
INSERT OR IGNORE INTO words (word) VALUES ('Deposition');
INSERT OR IGNORE INTO words (word) VALUES ('Detector');
INSERT OR IGNORE INTO words (word) VALUES ('Device');
INSERT OR IGNORE INTO words (word) VALUES ('Diagnostics');
INSERT OR IGNORE INTO words (word) VALUES ('Differential');
INSERT OR IGNORE INTO words (word) VALUES ('Diode');
INSERT OR IGNORE INTO words (word) VALUES ('Discrete');
INSERT OR IGNORE INTO words (word) VALUES ('Distillation');
INSERT OR IGNORE INTO words (word) VALUES ('DNA');
INSERT OR IGNORE INTO words (word) VALUES ('Drainage');
INSERT OR IGNORE INTO words (word) VALUES ('Dynamics');
INSERT OR IGNORE INTO words (word) VALUES ('Earthquake');
INSERT OR IGNORE INTO words (word) VALUES ('Easement');
INSERT OR IGNORE INTO words (word) VALUES ('Ecology');
INSERT OR IGNORE INTO words (word) VALUES ('Eigenvalue');
INSERT OR IGNORE INTO words (word) VALUES ('Electromagnetism');
INSERT OR IGNORE INTO words (word) VALUES ('Embedded');
INSERT OR IGNORE INTO words (word) VALUES ('Emergency');
INSERT OR IGNORE INTO words (word) VALUES ('Encryption');
INSERT OR IGNORE INTO words (word) VALUES ('Entropy');
INSERT OR IGNORE INTO words (word) VALUES ('Entrepreneurship');
INSERT OR IGNORE INTO words (word) VALUES ('Equilibrium');
INSERT OR IGNORE INTO words (word) VALUES ('Ergonomics');
INSERT OR IGNORE INTO words (word) VALUES ('Erosion');
INSERT OR IGNORE INTO words (word) VALUES ('Evacuation');
INSERT OR IGNORE INTO words (word) VALUES ('Expression');
INSERT OR IGNORE INTO words (word) VALUES ('Extraction');
INSERT OR IGNORE INTO words (word) VALUES ('Extinguisher');
INSERT OR IGNORE INTO words (word) VALUES ('Fatigue');
INSERT OR IGNORE INTO words (word) VALUES ('Feedback');
INSERT OR IGNORE INTO words (word) VALUES ('Fermentation');
INSERT OR IGNORE INTO words (word) VALUES ('Fiber');
INSERT OR IGNORE INTO words (word) VALUES ('Field');
INSERT OR IGNORE INTO words (word) VALUES ('Filter');
INSERT OR IGNORE INTO words (word) VALUES ('Finance');
INSERT OR IGNORE INTO words (word) VALUES ('Finite');
INSERT OR IGNORE INTO words (word) VALUES ('Flame');
INSERT OR IGNORE INTO words (word) VALUES ('Flashover');
INSERT OR IGNORE INTO words (word) VALUES ('Flooding');
INSERT OR IGNORE INTO words (word) VALUES ('Fluid');
INSERT OR IGNORE INTO words (word) VALUES ('Form');
INSERT OR IGNORE INTO words (word) VALUES ('Forecasting');
INSERT OR IGNORE INTO words (word) VALUES ('Foundation');
INSERT OR IGNORE INTO words (word) VALUES ('Fourier');
INSERT OR IGNORE INTO words (word) VALUES ('Frequency');
INSERT OR IGNORE INTO words (word) VALUES ('Friction');
INSERT OR IGNORE INTO words (word) VALUES ('Gear');
INSERT OR IGNORE INTO words (word) VALUES ('Genetics');
INSERT OR IGNORE INTO words (word) VALUES ('Genome');
INSERT OR IGNORE INTO words (word) VALUES ('Geodesy');
INSERT OR IGNORE INTO words (word) VALUES ('Geotechnics');
INSERT OR IGNORE INTO words (word) VALUES ('GIS');
INSERT OR IGNORE INTO words (word) VALUES ('GPS');
INSERT OR IGNORE INTO words (word) VALUES ('Graphene');
INSERT OR IGNORE INTO words (word) VALUES ('Grounding');
INSERT OR IGNORE INTO words (word) VALUES ('Habitat');
INSERT OR IGNORE INTO words (word) VALUES ('Hamiltonian');
INSERT OR IGNORE INTO words (word) VALUES ('Hardware');
INSERT OR IGNORE INTO words (word) VALUES ('Hazard');
INSERT OR IGNORE INTO words (word) VALUES ('Heat');
INSERT OR IGNORE INTO words (word) VALUES ('Highway');
INSERT OR IGNORE INTO words (word) VALUES ('Hydraulics');
INSERT OR IGNORE INTO words (word) VALUES ('Hydrology');
INSERT OR IGNORE INTO words (word) VALUES ('Ignition');
INSERT OR IGNORE INTO words (word) VALUES ('Imaging');
INSERT OR IGNORE INTO words (word) VALUES ('Impedance');
INSERT OR IGNORE INTO words (word) VALUES ('Implant');
INSERT OR IGNORE INTO words (word) VALUES ('Infrastructure');
INSERT OR IGNORE INTO words (word) VALUES ('Innovation');
INSERT OR IGNORE INTO words (word) VALUES ('Integration');
INSERT OR IGNORE INTO words (word) VALUES ('Interaction');
INSERT OR IGNORE INTO words (word) VALUES ('Interface');
INSERT OR IGNORE INTO words (word) VALUES ('Kinetics');
INSERT OR IGNORE INTO words (word) VALUES ('Kernel');
INSERT OR IGNORE INTO words (word) VALUES ('Landscape');
INSERT OR IGNORE INTO words (word) VALUES ('Latency');
INSERT OR IGNORE INTO words (word) VALUES ('Leadership');
INSERT OR IGNORE INTO words (word) VALUES ('Lean');
INSERT OR IGNORE INTO words (word) VALUES ('Legislation');
INSERT OR IGNORE INTO words (word) VALUES ('Levelling');
INSERT OR IGNORE INTO words (word) VALUES ('Lidar');
INSERT OR IGNORE INTO words (word) VALUES ('Linux');
INSERT OR IGNORE INTO words (word) VALUES ('Lithography');
INSERT OR IGNORE INTO words (word) VALUES ('Load');
INSERT OR IGNORE INTO words (word) VALUES ('Logistics');
INSERT OR IGNORE INTO words (word) VALUES ('Magnetic');
INSERT OR IGNORE INTO words (word) VALUES ('Management');
INSERT OR IGNORE INTO words (word) VALUES ('Manufacturing');
INSERT OR IGNORE INTO words (word) VALUES ('Mapping');
INSERT OR IGNORE INTO words (word) VALUES ('Marketing');
INSERT OR IGNORE INTO words (word) VALUES ('Material');
INSERT OR IGNORE INTO words (word) VALUES ('Matrix');
INSERT OR IGNORE INTO words (word) VALUES ('Mechanics');
INSERT OR IGNORE INTO words (word) VALUES ('Memory');
INSERT OR IGNORE INTO words (word) VALUES ('Metabolism');
INSERT OR IGNORE INTO words (word) VALUES ('Microcontroller');
INSERT OR IGNORE INTO words (word) VALUES ('Microorganism');
INSERT OR IGNORE INTO words (word) VALUES ('Mitigation');
INSERT OR IGNORE INTO words (word) VALUES ('Mixing');
INSERT OR IGNORE INTO words (word) VALUES ('Modelling');
INSERT OR IGNORE INTO words (word) VALUES ('Modulation');
INSERT OR IGNORE INTO words (word) VALUES ('Molecular');
INSERT OR IGNORE INTO words (word) VALUES ('Monitoring');
INSERT OR IGNORE INTO words (word) VALUES ('Motor');
INSERT OR IGNORE INTO words (word) VALUES ('MRI');
INSERT OR IGNORE INTO words (word) VALUES ('Mutation');
INSERT OR IGNORE INTO words (word) VALUES ('Nanofabrication');
INSERT OR IGNORE INTO words (word) VALUES ('Nanomaterial');
INSERT OR IGNORE INTO words (word) VALUES ('Nanoparticle');
INSERT OR IGNORE INTO words (word) VALUES ('Network');
INSERT OR IGNORE INTO words (word) VALUES ('Nitrogen');
INSERT OR IGNORE INTO words (word) VALUES ('Numerical');
INSERT OR IGNORE INTO words (word) VALUES ('Nutrient');
INSERT OR IGNORE INTO words (word) VALUES ('Operations');
INSERT OR IGNORE INTO words (word) VALUES ('Optical');
INSERT OR IGNORE INTO words (word) VALUES ('Optimization');
INSERT OR IGNORE INTO words (word) VALUES ('Organization');
INSERT OR IGNORE INTO words (word) VALUES ('Oscillator');
INSERT OR IGNORE INTO words (word) VALUES ('Ownership');
INSERT OR IGNORE INTO words (word) VALUES ('Packet');
INSERT OR IGNORE INTO words (word) VALUES ('Parallelism');
INSERT OR IGNORE INTO words (word) VALUES ('Parcel');
INSERT OR IGNORE INTO words (word) VALUES ('Particle');
INSERT OR IGNORE INTO words (word) VALUES ('Pathogen');
INSERT OR IGNORE INTO words (word) VALUES ('Pavement');
INSERT OR IGNORE INTO words (word) VALUES ('Phase');
INSERT OR IGNORE INTO words (word) VALUES ('Photogrammetry');
INSERT OR IGNORE INTO words (word) VALUES ('Photon');
INSERT OR IGNORE INTO words (word) VALUES ('Photonics');
INSERT OR IGNORE INTO words (word) VALUES ('Physiology');
INSERT OR IGNORE INTO words (word) VALUES ('Pipe');
INSERT OR IGNORE INTO words (word) VALUES ('Planning');
INSERT OR IGNORE INTO words (word) VALUES ('Plasma');
INSERT OR IGNORE INTO words (word) VALUES ('Plasmid');
INSERT OR IGNORE INTO words (word) VALUES ('Polymer');
INSERT OR IGNORE INTO words (word) VALUES ('Power');
INSERT OR IGNORE INTO words (word) VALUES ('Preparedness');
INSERT OR IGNORE INTO words (word) VALUES ('Pressure');
INSERT OR IGNORE INTO words (word) VALUES ('Probability');
INSERT OR IGNORE INTO words (word) VALUES ('Process');
INSERT OR IGNORE INTO words (word) VALUES ('Procurement');
INSERT OR IGNORE INTO words (word) VALUES ('Processor');
INSERT OR IGNORE INTO words (word) VALUES ('Product');
INSERT OR IGNORE INTO words (word) VALUES ('Productivity');
INSERT OR IGNORE INTO words (word) VALUES ('Project');
INSERT OR IGNORE INTO words (word) VALUES ('Projection');
INSERT OR IGNORE INTO words (word) VALUES ('Proof');
INSERT OR IGNORE INTO words (word) VALUES ('Prosthetics');
INSERT OR IGNORE INTO words (word) VALUES ('Protein');
INSERT OR IGNORE INTO words (word) VALUES ('Protocol');
INSERT OR IGNORE INTO words (word) VALUES ('Prototype');
INSERT OR IGNORE INTO words (word) VALUES ('Pump');
INSERT OR IGNORE INTO words (word) VALUES ('Quality');
INSERT OR IGNORE INTO words (word) VALUES ('Quantum');
INSERT OR IGNORE INTO words (word) VALUES ('Radiation');
INSERT OR IGNORE INTO words (word) VALUES ('Reaction');
INSERT OR IGNORE INTO words (word) VALUES ('Reactor');
INSERT OR IGNORE INTO words (word) VALUES ('Recovery');
INSERT OR IGNORE INTO words (word) VALUES ('Recursion');
INSERT OR IGNORE INTO words (word) VALUES ('Rectifier');
INSERT OR IGNORE INTO words (word) VALUES ('Refining');
INSERT OR IGNORE INTO words (word) VALUES ('Regulation');
INSERT OR IGNORE INTO words (word) VALUES ('Registry');
INSERT OR IGNORE INTO words (word) VALUES ('Rehabilitation');
INSERT OR IGNORE INTO words (word) VALUES ('Reinforcement');
INSERT OR IGNORE INTO words (word) VALUES ('Relay');
INSERT OR IGNORE INTO words (word) VALUES ('Remediation');
INSERT OR IGNORE INTO words (word) VALUES ('Rendering');
INSERT OR IGNORE INTO words (word) VALUES ('Resilience');
INSERT OR IGNORE INTO words (word) VALUES ('Resonance');
INSERT OR IGNORE INTO words (word) VALUES ('Response');
INSERT OR IGNORE INTO words (word) VALUES ('Restoration');
INSERT OR IGNORE INTO words (word) VALUES ('Risk');
INSERT OR IGNORE INTO words (word) VALUES ('Routing');
INSERT OR IGNORE INTO words (word) VALUES ('Safety');
INSERT OR IGNORE INTO words (word) VALUES ('Scale');
INSERT OR IGNORE INTO words (word) VALUES ('Scattering');
INSERT OR IGNORE INTO words (word) VALUES ('Scenario');
INSERT OR IGNORE INTO words (word) VALUES ('Sediment');
INSERT OR IGNORE INTO words (word) VALUES ('Semiconductor');
INSERT OR IGNORE INTO words (word) VALUES ('Sensor');
INSERT OR IGNORE INTO words (word) VALUES ('Separation');
INSERT OR IGNORE INTO words (word) VALUES ('Sequencing');
INSERT OR IGNORE INTO words (word) VALUES ('Series');
INSERT OR IGNORE INTO words (word) VALUES ('Shaft');
INSERT OR IGNORE INTO words (word) VALUES ('Signal');
INSERT OR IGNORE INTO words (word) VALUES ('Simulation');
INSERT OR IGNORE INTO words (word) VALUES ('Sketching');
INSERT OR IGNORE INTO words (word) VALUES ('Slurry');
INSERT OR IGNORE INTO words (word) VALUES ('Smoke');
INSERT OR IGNORE INTO words (word) VALUES ('Software');
INSERT OR IGNORE INTO words (word) VALUES ('Soil');
INSERT OR IGNORE INTO words (word) VALUES ('Solvent');
INSERT OR IGNORE INTO words (word) VALUES ('Species');
INSERT OR IGNORE INTO words (word) VALUES ('Spectroscopy');
INSERT OR IGNORE INTO words (word) VALUES ('Spectrum');
INSERT OR IGNORE INTO words (word) VALUES ('Sprinkler');
INSERT OR IGNORE INTO words (word) VALUES ('Statistics');
INSERT OR IGNORE INTO words (word) VALUES ('Sterility');
INSERT OR IGNORE INTO words (word) VALUES ('Stochastic');
INSERT OR IGNORE INTO words (word) VALUES ('Strategy');
INSERT OR IGNORE INTO words (word) VALUES ('Streaming');
INSERT OR IGNORE INTO words (word) VALUES ('Stress');
INSERT OR IGNORE INTO words (word) VALUES ('Structural');
INSERT OR IGNORE INTO words (word) VALUES ('Suppression');
INSERT OR IGNORE INTO words (word) VALUES ('Surveying');
INSERT OR IGNORE INTO words (word) VALUES ('Sustainability');
INSERT OR IGNORE INTO words (word) VALUES ('Symmetry');
INSERT OR IGNORE INTO words (word) VALUES ('Synthesis');
INSERT OR IGNORE INTO words (word) VALUES ('Temperature');
INSERT OR IGNORE INTO words (word) VALUES ('Tensor');
INSERT OR IGNORE INTO words (word) VALUES ('Terrorism');
INSERT OR IGNORE INTO words (word) VALUES ('Theorem');
INSERT OR IGNORE INTO words (word) VALUES ('Therapy');
INSERT OR IGNORE INTO words (word) VALUES ('Thermal');
INSERT OR IGNORE INTO words (word) VALUES ('Thermodynamics');
INSERT OR IGNORE INTO words (word) VALUES ('Threat');
INSERT OR IGNORE INTO words (word) VALUES ('Throughput');
INSERT OR IGNORE INTO words (word) VALUES ('Tissue');
INSERT OR IGNORE INTO words (word) VALUES ('Tolerance');
INSERT OR IGNORE INTO words (word) VALUES ('Topology');
INSERT OR IGNORE INTO words (word) VALUES ('Torque');
INSERT OR IGNORE INTO words (word) VALUES ('Toxicity');
INSERT OR IGNORE INTO words (word) VALUES ('Traffic');
INSERT OR IGNORE INTO words (word) VALUES ('Transistor');
INSERT OR IGNORE INTO words (word) VALUES ('Transmission');
INSERT OR IGNORE INTO words (word) VALUES ('Tunnel');
INSERT OR IGNORE INTO words (word) VALUES ('Ultrasound');
INSERT OR IGNORE INTO words (word) VALUES ('Uncertainty');
INSERT OR IGNORE INTO words (word) VALUES ('Usability');
INSERT OR IGNORE INTO words (word) VALUES ('Vegetation');
INSERT OR IGNORE INTO words (word) VALUES ('Ventilation');
INSERT OR IGNORE INTO words (word) VALUES ('Vibration');
INSERT OR IGNORE INTO words (word) VALUES ('Virtualization');
INSERT OR IGNORE INTO words (word) VALUES ('Viscosity');
INSERT OR IGNORE INTO words (word) VALUES ('Visualization');
INSERT OR IGNORE INTO words (word) VALUES ('Voltage');
INSERT OR IGNORE INTO words (word) VALUES ('Vulnerability');
INSERT OR IGNORE INTO words (word) VALUES ('Watershed');
INSERT OR IGNORE INTO words (word) VALUES ('Wave');
INSERT OR IGNORE INTO words (word) VALUES ('Waveform');
INSERT OR IGNORE INTO words (word) VALUES ('Wearable');
INSERT OR IGNORE INTO words (word) VALUES ('Welding');
INSERT OR IGNORE INTO words (word) VALUES ('Wetland');
INSERT OR IGNORE INTO words (word) VALUES ('Wireless');
INSERT OR IGNORE INTO words (word) VALUES ('Yield');
INSERT OR IGNORE INTO words (word) VALUES ('Zoning');

-- ── word_programs (join rows) ─────────────────────────────────
-- B — Bioteknik
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='DNA'              AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Genetics'         AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Fermentation'     AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Genome'           AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Bioreactor'       AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Metabolism'       AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Cloning'          AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Microorganism'    AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Antibody'         AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Tissue'           AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Chromatography'   AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Plasmid'          AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Mutation'         AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Culture'          AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Sequencing'       AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Pathogen'         AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Expression'       AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Bioprocess'       AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Sterility'        AND p.code='B';
-- B shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Catalyst'         AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Cell'             AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Molecular'        AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Protein'          AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Spectroscopy'     AND p.code='B';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Synthesis'        AND p.code='B';

-- BR — Brandteknik
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Sprinkler'        AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Smoke'            AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Flashover'        AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Detector'         AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Toxicity'         AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Egress'           AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Heat'             AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Ignition'         AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Flame'            AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Extinguisher'     AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Building'         AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Code'             AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Suppression'      AND p.code='BR';
-- BR shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Combustion'       AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Evacuation'       AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Hydraulics'       AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Radiation'        AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Risk'             AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Safety'           AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Sensor'           AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Simulation'       AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Temperature'      AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Thermal'          AND p.code='BR';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Ventilation'      AND p.code='BR';

-- C — Informations- och kommunikationsteknik
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Bandwidth'        AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Encryption'       AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Routing'          AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Wireless'         AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Fiber'            AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Modulation'       AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Latency'          AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Compression'      AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Streaming'        AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Authentication'   AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Spectrum'         AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Packet'           AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Throughput'       AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Transmission'     AND p.code='C';
-- C shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Antenna'          AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Architecture'     AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Cloud'            AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Coding'           AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Cybersecurity'    AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Interface'        AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Network'          AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Protocol'         AND p.code='C';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Signal'           AND p.code='C';

-- D — Datateknik
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Algorithm'        AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Compiler'         AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Database'         AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Software'         AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Hardware'         AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Debugging'        AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Kernel'           AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Parallelism'      AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Memory'           AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Cache'            AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Assembly'         AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Linux'            AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Recursion'        AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Processor'        AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Virtualization'   AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Cryptography'     AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='API'              AND p.code='D';
-- D shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Architecture'     AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Cloud'            AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Cybersecurity'    AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Embedded'         AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Network'          AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Optimization'     AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Protocol'         AND p.code='D';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Simulation'       AND p.code='D';

-- E — Elektroteknik
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Circuit'          AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Voltage'          AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Inductance'       AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Capacitor'        AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Oscillator'       AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Amplifier'        AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Impedance'        AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Rectifier'        AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Microcontroller'  AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Filter'           AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Waveform'         AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Grounding'        AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Relay'            AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Conductor'        AND p.code='E';
-- E shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Antenna'          AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Diode'            AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Embedded'         AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Frequency'        AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Motor'            AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Power'            AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Resonance'        AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Semiconductor'    AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Sensor'           AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Signal'           AND p.code='E';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Transistor'       AND p.code='E';

-- F — Teknisk fysik
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Relativity'       AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Wave'             AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Electromagnetism' AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Particle'         AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Plasma'           AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Tensor'           AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Symmetry'         AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Scattering'       AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Field'            AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Entropy'          AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Hamiltonian'      AND p.code='F';
-- F shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Differential'     AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Finite'           AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Frequency'        AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Mechanics'        AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Optical'          AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Photon'           AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Photonics'        AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Quantum'          AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Radiation'        AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Resonance'        AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Semiconductor'    AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Simulation'       AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Spectroscopy'     AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Thermodynamics'   AND p.code='F';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Uncertainty'      AND p.code='F';

-- I — Industriell ekonomi
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Finance'          AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Logistics'        AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Strategy'         AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Marketing'        AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Leadership'       AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Operations'       AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Lean'             AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Procurement'      AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Forecasting'      AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Management'       AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Cost'             AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Productivity'     AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Accounting'       AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Entrepreneurship' AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Business'         AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Organization'     AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Decision'         AND p.code='I';
-- I shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Innovation'       AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Optimization'     AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Planning'         AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Process'          AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Project'          AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Quality'          AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Risk'             AND p.code='I';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Sustainability'   AND p.code='I';

-- K — Kemiteknik
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Reaction'         AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Distillation'     AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Reactor'          AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Solvent'          AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Polymer'          AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Absorption'       AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Equilibrium'      AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Phase'            AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Separation'       AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Crystallization'  AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Corrosion'        AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Yield'            AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Kinetics'         AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Refining'         AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Extraction'       AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Slurry'           AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Viscosity'        AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Mixing'           AND p.code='K';
-- K shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Catalyst'         AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Combustion'       AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Fluid'            AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Pressure'         AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Process'          AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Synthesis'        AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Temperature'      AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Thermal'          AND p.code='K';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Thermodynamics'   AND p.code='K';

-- L — Lantmäteri
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Surveying'        AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Cadastre'         AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Mapping'          AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Property'         AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Coordinate'       AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='GPS'              AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Photogrammetry'   AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Boundary'         AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Zoning'           AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Geodesy'          AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Lidar'            AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Ownership'        AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Registry'         AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Easement'         AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Scale'            AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Projection'       AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Parcel'           AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Delineation'      AND p.code='L';
-- L shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='GIS'              AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Infrastructure'   AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Planning'         AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Topology'         AND p.code='L';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Visualization'    AND p.code='L';

-- M — Maskinteknik
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Dynamics'         AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Fatigue'          AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Vibration'        AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Welding'          AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Bearing'          AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Gear'             AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Torque'           AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Casting'          AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Friction'         AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Compressor'       AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Shaft'            AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Pump'             AND p.code='M';
-- M shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='CAD'              AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Finite'           AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Fluid'            AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Hydraulics'       AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Manufacturing'    AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Material'         AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Mechanics'        AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Motor'            AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Power'            AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Pressure'         AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Project'          AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Quality'          AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Simulation'       AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Stress'           AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Structural'       AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Sustainability'   AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Thermal'          AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Thermodynamics'   AND p.code='M';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Tolerance'        AND p.code='M';

-- MD — Maskinteknik med teknisk design
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Ergonomics'       AND p.code='MD';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Prototype'        AND p.code='MD';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Rendering'        AND p.code='MD';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Aesthetics'       AND p.code='MD';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Sketching'        AND p.code='MD';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Usability'        AND p.code='MD';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Concept'          AND p.code='MD';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Form'             AND p.code='MD';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Interaction'      AND p.code='MD';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Feedback'         AND p.code='MD';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Product'          AND p.code='MD';
-- MD shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Biomechanics'     AND p.code='MD';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='CAD'              AND p.code='MD';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Innovation'       AND p.code='MD';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Interface'        AND p.code='MD';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Manufacturing'    AND p.code='MD';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Material'         AND p.code='MD';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Stress'           AND p.code='MD';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Sustainability'   AND p.code='MD';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Tolerance'        AND p.code='MD';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Visualization'    AND p.code='MD';

-- BME — Medicin och teknik
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Imaging'          AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Implant'          AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Prosthetics'      AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Physiology'       AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Diagnostics'      AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='MRI'              AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Regulation'       AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Biocompatibility' AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Clinical'         AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Rehabilitation'   AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Anatomy'          AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Wearable'         AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Biomaterials'     AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Ultrasound'       AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Device'           AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Therapy'          AND p.code='BME';
-- BME shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Biomechanics'     AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Cell'             AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Monitoring'       AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Protein'          AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Sensor'           AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Signal'           AND p.code='BME';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Simulation'       AND p.code='BME';

-- N — Teknisk nanovetenskap
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Nanomaterial'     AND p.code='N';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Graphene'         AND p.code='N';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Nanofabrication'  AND p.code='N';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Crystal'          AND p.code='N';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Deposition'       AND p.code='N';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Nanoparticle'     AND p.code='N';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Lithography'      AND p.code='N';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Magnetic'         AND p.code='N';
-- N shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Diode'            AND p.code='N';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Interface'        AND p.code='N';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Molecular'        AND p.code='N';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Optical'          AND p.code='N';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Photon'           AND p.code='N';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Photonics'        AND p.code='N';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Quantum'          AND p.code='N';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Semiconductor'    AND p.code='N';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Sensor'           AND p.code='N';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Spectroscopy'     AND p.code='N';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Transistor'       AND p.code='N';

-- Pi — Teknisk matematik
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Stochastic'       AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Matrix'           AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Fourier'          AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Numerical'        AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Statistics'       AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Convergence'      AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Integration'      AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Eigenvalue'       AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Proof'            AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Discrete'         AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Regression'       AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Computation'      AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Approximation'    AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Theorem'          AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Series'           AND p.code='Pi';
-- Pi shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Coding'           AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Differential'     AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Modelling'        AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Optimization'     AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Probability'      AND p.code='Pi';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Topology'         AND p.code='Pi';

-- R — Risk, säkerhet och krishantering
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Vulnerability'    AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Preparedness'     AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Threat'           AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Assessment'       AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Mitigation'       AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Emergency'        AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Crisis'           AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Response'         AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Hazard'           AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Consequence'      AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Scenario'         AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Legislation'      AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Communication'    AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Terrorism'        AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Flooding'         AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Recovery'         AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Coordination'     AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Continuity'       AND p.code='R';
-- R shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Evacuation'       AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Infrastructure'   AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Monitoring'       AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Probability'      AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Resilience'       AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Risk'             AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Safety'           AND p.code='R';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Uncertainty'      AND p.code='R';

-- V — Väg- och vattenbyggnad
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Bridge'           AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Asphalt'          AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Foundation'       AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Geotechnics'      AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Drainage'         AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Concrete'         AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Traffic'          AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Reinforcement'    AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Tunnel'           AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Pavement'         AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Load'             AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Construction'     AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Highway'          AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Dam'              AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Earthquake'       AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Column'           AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Pipe'             AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Levelling'        AND p.code='V';
-- V shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Hydraulics'       AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Hydrology'        AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Infrastructure'   AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Soil'             AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Structural'       AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Sustainability'   AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Ventilation'      AND p.code='V';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Watershed'        AND p.code='V';

-- W — Ekosystemteknik
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Ecology'          AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Biodiversity'     AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Carbon'           AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Restoration'      AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Species'          AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Wetland'          AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Nutrient'         AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Pollution'        AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Climate'          AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Vegetation'       AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Biogeochemistry'  AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Landscape'        AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Sediment'         AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Habitat'          AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Erosion'          AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Aquifer'          AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Nitrogen'         AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Remediation'      AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Conservation'     AND p.code='W';
-- W shared
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='GIS'              AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Hydrology'        AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Modelling'        AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Resilience'       AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Soil'             AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Sustainability'   AND p.code='W';
INSERT OR IGNORE INTO word_programs SELECT w.id, p.id FROM words w, programs p WHERE w.word='Watershed'        AND p.code='W';