CREATE TABLE sqlpQL_Project"."CovidDeaths"
(iso_code varchar,
 continent varchar,
 location varchar,
 date date,
 population varchar,
 total_cases varchar,
 new_cases varchar,
 new_cases_smoothed varchar,
 total_deaths varchar,
 new_deaths varchar,
 new_deaths_smoothed varchar,
 total_cases_per_million varchar,
 new_cases_per_million varchar,
 new_cases_smoothed_per_million varchar,
 total_deaths_per_million varchar,
 new_deaths_per_million varchar,
 new_deaths_smoothed_per_million varchar,
 reproduction_rate varchar,
 icu_patients varchar,
 icu_patients_per_million varchar,
 hosp_patients varchar,
 hosp_patients_per_million varchar,
 weekly_icu_admissions varchar,
 weekly_icu_admissions_per_million varchar,
 weekly_hosp_admissions	varchar,
 weekly_hosp_admissions_per_million varchar 
)
;

ALTER TABLE IF EXISTS "SQL_Project"."CovidDeaths"
    OWNER to postgres;