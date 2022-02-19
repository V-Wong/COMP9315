create type SchemaTuple as ("table" text, "attributes" text);

create or replace function schema1() returns setof SchemaTuple
as $$
declare
	rec record;
	rel text := '';
	att text := '';
	len integer := 0;
begin
	for rec in
		select relname, attname, atttypid, atttypmod
		from   pg_class t, pg_attribute a, pg_namespace n
		where  t.relkind='r'
			and t.relnamespace = n.oid
			and n.nspname = 'public'
			and attrelid = t.oid
			and attnum > 0
		order by relname, attnum
	loop
		if (rec.relname <> rel) then
			if (rel <> '') then
				return next (rel::text, att::text);
			end if;
			rel := rec.relname;
			att := '';
			len := 0;
		end if;
		if (att <> '') then
			att := att || ', ';
			len := len + 2;
		end if;
		if (len + length(rec.attname) > 70) then
			att := att || E'\n        ';
			len := 0;
		end if;
		att := att || nice_format(rec.attname, rec.atttypid, rec.atttypmod);
		len := len + length(nice_format(rec.attname, rec.atttypid, rec.atttypmod));
	end loop;
	-- deal with last table
	if (rel <> '') then
		return next (rel::text, att::text);
	end if;
end;
$$ language plpgsql;

create or replace function nice_format(attname name, atttypid oid, atttypmod integer) returns text
as $$
declare
	typename name;
begin
	select typname into typename
	from pg_type
	where oid = atttypid;

	if typename = 'int4' then
		return attname || ':integer';
	elsif typename = 'float8' then
		return attname || ':float';
	elsif typename = 'varchar' then
		return attname || ':varchar(' || atttypmod - 4 || ')';
	elsif typename = 'bpchar' then
		return attname || ':char(' || atttypmod - 4 || ')';
	else
		return attname || ':' || typename;
	end if;
end; 
$$ language plpgsql;
