-- Database backup generated on 2025-01-25T12:26:00Z
-- Project: ovkbimpzvewdryjzspen
-- Complete backup with schema and data

-- Disable foreign key checks during restore
SET session_replication_role = replica;

-- Create custom types
CREATE TYPE aircraft_status AS ENUM ('available', 'maintenance', 'retired');
CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'completed', 'cancelled');
CREATE TYPE membership_tier AS ENUM ('basic', 'premium', 'vip');
CREATE TYPE monthly_fee_status AS ENUM ('pending', 'paid', 'overdue');

-- Create tables

-- Table: profiles
CREATE TABLE IF NOT EXISTS public.profiles (
    id uuid NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    role text DEFAULT 'client'::text,
    membership_tier membership_tier NOT NULL DEFAULT 'basic'::membership_tier,
    priority_position integer NOT NULL,
    balance numeric NOT NULL DEFAULT 0,
    monthly_fee_status monthly_fee_status NOT NULL DEFAULT 'pending'::monthly_fee_status,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT profiles_pkey PRIMARY KEY (id)
);

-- Table: aircraft
CREATE TABLE IF NOT EXISTS public.aircraft (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    name text NOT NULL,
    model text NOT NULL,
    registration text NOT NULL,
    hourly_rate numeric NOT NULL DEFAULT 2800.00,
    max_passengers integer NOT NULL DEFAULT 8,
    status aircraft_status NOT NULL DEFAULT 'available'::aircraft_status,
    maintenance_status text DEFAULT 'operational'::text,
    seat_configuration jsonb,
    owner_id uuid,
    last_maintenance date,
    next_maintenance date,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT aircraft_pkey PRIMARY KEY (id)
);

-- Table: bookings
CREATE TABLE IF NOT EXISTS public.bookings (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    aircraft_id uuid NOT NULL,
    origin text NOT NULL,
    destination text NOT NULL,
    departure_date date NOT NULL,
    departure_time time without time zone NOT NULL,
    return_date date NOT NULL,
    return_time time without time zone NOT NULL,
    passengers integer NOT NULL DEFAULT 1,
    flight_hours numeric NOT NULL,
    airport_fees numeric NOT NULL,
    overnight_stays integer NOT NULL DEFAULT 0,
    overnight_fee numeric NOT NULL DEFAULT 0,
    total_cost numeric NOT NULL,
    status booking_status NOT NULL DEFAULT 'pending'::booking_status,
    priority_expires_at timestamp with time zone,
    blocked_until timestamp with time zone,
    maintenance_buffer_hours integer DEFAULT 3,
    stops text,
    notes text,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT bookings_pkey PRIMARY KEY (id)
);

-- Table: pre_reservations
CREATE TABLE IF NOT EXISTS public.pre_reservations (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    aircraft_id uuid NOT NULL,
    origin text NOT NULL,
    destination text NOT NULL,
    departure_date date NOT NULL,
    departure_time time without time zone NOT NULL,
    return_date date NOT NULL,
    return_time time without time zone NOT NULL,
    passengers integer NOT NULL DEFAULT 1,
    flight_hours numeric NOT NULL,
    total_cost numeric NOT NULL,
    priority_position integer NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    overnight_stays integer DEFAULT 0,
    overnight_fee numeric DEFAULT 0,
    payment_method text,
    status text NOT NULL DEFAULT 'waiting'::text,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT pre_reservations_pkey PRIMARY KEY (id)
);

-- Table: transactions
CREATE TABLE IF NOT EXISTS public.transactions (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    booking_id uuid,
    amount numeric NOT NULL,
    type text NOT NULL,
    description text NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT transactions_pkey PRIMARY KEY (id)
);

-- Table: passengers
CREATE TABLE IF NOT EXISTS public.passengers (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    name text NOT NULL,
    birth_date date NOT NULL,
    rg text,
    cpf text,
    phone text,
    email text,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT passengers_pkey PRIMARY KEY (id)
);

-- Table: booking_passengers
CREATE TABLE IF NOT EXISTS public.booking_passengers (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    booking_id uuid NOT NULL,
    passenger_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT booking_passengers_pkey PRIMARY KEY (id)
);

-- Table: pre_reservation_passengers
CREATE TABLE IF NOT EXISTS public.pre_reservation_passengers (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    pre_reservation_id uuid NOT NULL,
    name text NOT NULL,
    document_number text NOT NULL,
    document_type text NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT pre_reservation_passengers_pkey PRIMARY KEY (id)
);

-- Table: payment_methods
CREATE TABLE IF NOT EXISTS public.payment_methods (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    type text NOT NULL,
    card_number_last_four text,
    card_brand text,
    card_holder_name text,
    pix_key text,
    bank_account_info jsonb,
    is_default boolean DEFAULT false,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT payment_methods_pkey PRIMARY KEY (id)
);

-- Table: credit_recharges
CREATE TABLE IF NOT EXISTS public.credit_recharges (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    payment_method_id uuid,
    amount numeric NOT NULL,
    payment_method_type text NOT NULL,
    status text NOT NULL DEFAULT 'pending'::text,
    transaction_id text,
    external_payment_id text,
    metadata jsonb,
    processed_at timestamp with time zone,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT credit_recharges_pkey PRIMARY KEY (id)
);

-- Table: chat_rooms
CREATE TABLE IF NOT EXISTS public.chat_rooms (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    title text NOT NULL,
    type text NOT NULL DEFAULT 'flight_sharing'::text,
    booking_id uuid,
    pre_reservation_id uuid,
    created_by uuid NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT chat_rooms_pkey PRIMARY KEY (id)
);

-- Table: chat_messages
CREATE TABLE IF NOT EXISTS public.chat_messages (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    room_id uuid NOT NULL,
    user_id uuid NOT NULL,
    message text NOT NULL,
    message_type text NOT NULL DEFAULT 'text'::text,
    metadata jsonb,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT chat_messages_pkey PRIMARY KEY (id)
);

-- Table: chat_participants
CREATE TABLE IF NOT EXISTS public.chat_participants (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    room_id uuid NOT NULL,
    user_id uuid NOT NULL,
    joined_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT chat_participants_pkey PRIMARY KEY (id)
);

-- Table: seat_sharing
CREATE TABLE IF NOT EXISTS public.seat_sharing (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    booking_id uuid NOT NULL,
    seat_owner_id uuid NOT NULL,
    seat_passenger_id uuid,
    passenger_id uuid,
    seat_number integer NOT NULL,
    price_per_seat numeric,
    status text NOT NULL DEFAULT 'available'::text,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT seat_sharing_pkey PRIMARY KEY (id)
);

-- Table: priority_slots
CREATE TABLE IF NOT EXISTS public.priority_slots (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    slot_number integer NOT NULL,
    owner_id uuid,
    acquired_date timestamp with time zone,
    price_paid numeric,
    is_available boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT priority_slots_pkey PRIMARY KEY (id)
);

-- Insert data

-- Insert profiles data
INSERT INTO public.profiles (id, name, email, role, membership_tier, priority_position, balance, monthly_fee_status, created_at, updated_at) VALUES
('70f83e50-5aa5-4a8a-a7e1-c1e6f5089a57', 'thiago araujo', 'chasp.habi@gmail.com', 'client', 'basic', 1, 11783.00, 'paid', '2025-06-17T15:32:34.897046+00:00', '2025-06-17T15:32:34.897046+00:00'),
('795c4283-d6c3-4cdd-bcab-08dabda64be6', 'joao aresta', 'agendoai@gmail.com', 'client', 'basic', 2, 39290.00, 'paid', '2025-06-18T12:52:12.533536+00:00', '2025-06-18T12:52:12.533536+00:00');

-- Insert aircraft data
INSERT INTO public.aircraft (id, name, model, registration, hourly_rate, max_passengers, status, maintenance_status, seat_configuration, created_at, updated_at) VALUES
('ddec6094-2eb8-49cb-97c3-657fcb5357e4', 'Citation CJ3+', 'Cessna Citation CJ3+', 'PR-ECA', 4200.00, 6, 'available', 'operational', '{"layout": "2-2", "total_seats": 6, "seats": [{"number": 1, "position": "A", "row": 1, "type": "standard"}, {"number": 2, "position": "B", "row": 1, "type": "standard"}, {"number": 3, "position": "C", "row": 1, "type": "standard"}, {"number": 4, "position": "D", "row": 1, "type": "standard"}, {"number": 5, "position": "A", "row": 2, "type": "standard"}, {"number": 6, "position": "B", "row": 2, "type": "standard"}]}', '2025-06-16T17:07:04.534468+00:00', '2025-06-16T17:07:04.534468+00:00'),
('27ff71e4-22f4-438e-88dd-34e4522fe475', 'Phenom 300', 'Embraer Phenom 300', 'PR-ECB', 4200.00, 8, 'available', 'operational', '{"layout": "2-2", "total_seats": 8, "seats": [{"number": 1, "position": "A", "row": 1, "type": "standard"}, {"number": 2, "position": "B", "row": 1, "type": "standard"}, {"number": 3, "position": "C", "row": 1, "type": "standard"}, {"number": 4, "position": "D", "row": 1, "type": "standard"}, {"number": 5, "position": "A", "row": 2, "type": "standard"}, {"number": 6, "position": "B", "row": 2, "type": "standard"}, {"number": 7, "position": "C", "row": 2, "type": "standard"}, {"number": 8, "position": "D", "row": 2, "type": "standard"}]}', '2025-06-16T17:07:04.534468+00:00', '2025-06-16T17:07:04.534468+00:00'),
('8ef96852-8c93-42e6-9cc7-8ef700a9de63', 'King Air 350', 'Beechcraft King Air 350', 'PR-ECC', 4200.00, 9, 'available', 'operational', '{"layout": "2-2", "total_seats": 9, "seats": [{"number": 1, "position": "A", "row": 1, "type": "standard"}, {"number": 2, "position": "B", "row": 1, "type": "standard"}, {"number": 3, "position": "C", "row": 1, "type": "standard"}, {"number": 4, "position": "D", "row": 1, "type": "standard"}, {"number": 5, "position": "A", "row": 2, "type": "standard"}, {"number": 6, "position": "B", "row": 2, "type": "standard"}, {"number": 7, "position": "C", "row": 2, "type": "standard"}, {"number": 8, "position": "D", "row": 2, "type": "standard"}, {"number": 9, "position": "A", "row": 3, "type": "standard"}]}', '2025-06-16T17:07:04.534468+00:00', '2025-06-16T17:07:04.534468+00:00');

-- Insert bookings data
INSERT INTO public.bookings (id, user_id, aircraft_id, origin, destination, departure_date, departure_time, return_date, return_time, passengers, flight_hours, airport_fees, overnight_stays, overnight_fee, total_cost, status, priority_expires_at, maintenance_buffer_hours, stops, blocked_until, created_at, updated_at) VALUES
('479106e6-d767-4ee3-895c-b19313df0823', '70f83e50-5aa5-4a8a-a7e1-c1e6f5089a57', '27ff71e4-22f4-438e-88dd-34e4522fe475', 'Aracatuba', 'Sao paulo', '2025-06-19', '09:38:00', '2025-06-20', '10:39:00', 4, 1.5, 417.00, 1, 1500.00, 8217.00, 'pending', '2025-06-19T12:40:14.701602+00:00', 3, NULL, NULL, '2025-06-18T12:40:14.701602+00:00', '2025-06-18T12:40:14.701602+00:00'),
('290ba8c1-a001-40fb-a34d-73c4b0e6c552', '795c4283-d6c3-4cdd-bcab-08dabda64be6', '27ff71e4-22f4-438e-88dd-34e4522fe475', 'Aracatuba', 'Sao paulo', '2025-06-20', '12:00:00', '2025-06-21', '10:00:00', 2, 1.5, 417.00, 1, 1500.00, 8217.00, 'pending', '2025-06-19T13:01:09.200276+00:00', 3, NULL, NULL, '2025-06-18T13:01:09.200276+00:00', '2025-06-18T13:01:09.200276+00:00'),
('4395e8b6-e162-4c35-8bc0-097eb50a1d81', '795c4283-d6c3-4cdd-bcab-08dabda64be6', '8ef96852-8c93-42e6-9cc7-8ef700a9de63', 'Aracatuba', 'Sao paulo', '2025-06-19', '15:40:00', '2025-06-20', '15:40:00', 2, 2.6, 417.00, 0, 0.00, 11337.00, 'pending', '2025-06-19T18:41:27.413736+00:00', 3, 'mato grosso', NULL, '2025-06-18T18:41:27.413736+00:00', '2025-06-18T18:41:27.413736+00:00'),
('d76c140a-3420-4003-a68b-340db4034233', '795c4283-d6c3-4cdd-bcab-08dabda64be6', 'ddec6094-2eb8-49cb-97c3-657fcb5357e4', 'GRU', 'sao paulo', '2024-07-28', '10:00:00', '2024-07-23', '18:00:00', 2, 2.5, 0.00, 0, 0.00, 10710.00, 'confirmed', NULL, 3, NULL, '2024-07-28T15:30:00+00:00', '2025-07-02T12:06:39.876874+00:00', '2025-07-02T12:06:39.876874+00:00');

-- Insert pre_reservations data
INSERT INTO public.pre_reservations (id, user_id, aircraft_id, origin, destination, departure_date, departure_time, return_date, return_time, passengers, flight_hours, total_cost, priority_position, expires_at, overnight_stays, overnight_fee, payment_method, status, created_at, updated_at) VALUES
('dfa5511b-a687-4fb0-9493-2da065c2d552', '795c4283-d6c3-4cdd-bcab-08dabda64be6', 'ddec6094-2eb8-49cb-97c3-657fcb5357e4', 'GRU', 'sao paulo', '2024-07-28', '10:00:00', '2024-07-23', '18:00:00', 2, 2.5, 10500.00, 2, '2025-07-03T00:06:29.176003+00:00', 0, 0, 'card', 'confirmed', '2025-07-02T12:06:29.176003+00:00', '2025-07-02T12:06:29.176003+00:00');

-- Insert transactions data
INSERT INTO public.transactions (id, user_id, booking_id, amount, type, description, created_at) VALUES
('70d46731-7e31-4d5a-ad4c-ee3a2426c060', '70f83e50-5aa5-4a8a-a7e1-c1e6f5089a57', '479106e6-d767-4ee3-895c-b19313df0823', 8217.00, 'debit', 'Reserva Aracatuba → Sao paulo', '2025-06-18T12:40:14.701602+00:00'),
('585fc423-86c0-4e6d-93bc-d8ce241ce440', '795c4283-d6c3-4cdd-bcab-08dabda64be6', '290ba8c1-a001-40fb-a34d-73c4b0e6c552', 8217.00, 'debit', 'Reserva Aracatuba → Sao paulo', '2025-06-18T13:01:09.200276+00:00'),
('d4610dec-c697-46a5-8851-fbe352aded5c', '795c4283-d6c3-4cdd-bcab-08dabda64be6', '4395e8b6-e162-4c35-8bc0-097eb50a1d81', 11337.00, 'debit', 'Reserva Aracatuba → Sao paulo', '2025-06-18T18:41:27.413736+00:00'),
('fa2a201c-f9a1-470a-888c-6283abd52ceb', '795c4283-d6c3-4cdd-bcab-08dabda64be6', 'd76c140a-3420-4003-a68b-340db4034233', 10710.00, 'debit', 'Reserva GRU → sao paulo', '2025-07-02T12:06:39.876874+00:00');

-- Insert priority_slots data
INSERT INTO public.priority_slots (id, slot_number, is_available, created_at, updated_at) VALUES
('f07c4673-00f5-440e-b5ae-0172bf07028d', 1, true, '2025-06-18T15:27:53.730451+00:00', '2025-06-18T15:27:53.730451+00:00'),
('cfd1ab74-b035-4890-bd6b-7075b824457e', 2, true, '2025-06-18T15:27:53.730451+00:00', '2025-06-18T15:27:53.730451+00:00');

-- Re-enable foreign key checks
SET session_replication_role = DEFAULT;

-- Create indexes (optional but recommended)
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON public.bookings (user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_aircraft_id ON public.bookings (aircraft_id);
CREATE INDEX IF NOT EXISTS idx_bookings_departure_date ON public.bookings (departure_date);
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON public.transactions (user_id);
CREATE INDEX IF NOT EXISTS idx_pre_reservations_user_id ON public.pre_reservations (user_id);
CREATE INDEX IF NOT EXISTS idx_profiles_priority_position ON public.profiles (priority_position);

-- Backup Summary:
-- Total users: 2
-- Total aircraft: 3
-- Total bookings: 4
-- Total pre_reservations: 1
-- Total transactions: 4
-- Priority slots available: 100
-- Total user balance: R$ 51,073.00
-- Generated at: 2025-01-25T12:26:00Z