-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.categories (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  name text NOT NULL,
  label_key text,
  icon_code_point integer,
  icon_font_family text,
  image_url text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT categories_pkey PRIMARY KEY (id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  email text UNIQUE,
  fullname text,
  telephone text,
  role text DEFAULT 'client'::text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.clients (
  id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT clients_pkey PRIMARY KEY (id),
  CONSTRAINT clients_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.commercants (
  id uuid NOT NULL,
  nationality_id text,
  nationality_card_front_url text,
  nationality_card_back_url text,
  premiere_connexion boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT commercants_pkey PRIMARY KEY (id),
  CONSTRAINT commercants_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.shops (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  description text,
  image_url text,
  rating double precision DEFAULT 0.0,
  review_count integer DEFAULT 0,
  merchant_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT shops_pkey PRIMARY KEY (id),
  CONSTRAINT shops_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES auth.users(id)
);
CREATE TABLE public.shop_categories (
  shop_id uuid NOT NULL,
  category_id bigint NOT NULL,
  CONSTRAINT shop_categories_pkey PRIMARY KEY (shop_id, category_id),
  CONSTRAINT shop_categories_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id),
  CONSTRAINT shop_categories_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id)
);
CREATE TABLE public.products (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  price text,
  price_value integer,
  is_dark boolean DEFAULT false,
  image_url text,
  category_id bigint,
  sizes ARRAY,
  shop_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT products_pkey PRIMARY KEY (id),
  CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id),
  CONSTRAINT products_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id)
);
CREATE TABLE public.orders (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  client_id uuid,
  shop_id uuid,
  total_price integer NOT NULL,
  status text DEFAULT 'pending'::text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT orders_pkey PRIMARY KEY (id),
  CONSTRAINT orders_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.users(id),
  CONSTRAINT orders_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id)
);
CREATE TABLE public.order_items (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  order_id uuid,
  product_id uuid,
  quantity integer NOT NULL DEFAULT 1,
  price_at_time integer NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT order_items_pkey PRIMARY KEY (id),
  CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id),
  CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);