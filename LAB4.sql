set serveroutput on

--zad1

ACCEPT input_dataur PROMPT 'wprowadz date urodzenia';
DECLARE
  data_ur date;
  roznica number(10);
  input_error_exception EXCEPTION;
BEGIN
  data_ur:=to_date('&input_dataur', 'DD/MM/YYYY');
  IF 
    EXTRACT(MONTH FROM data_ur)>12 OR EXTRACT (MONTH FROM data_ur)<1
  THEN 
    RAISE input_error_exception;
  ELSIF
    EXTRACT(DAY FROM data_ur)>31 OR EXTRACT(DAY FROM data_ur)<1
  THEN
    RAISE input_error_exception;
  ELSE
    roznica:=SYSDATE-data_ur;
    DBMS_OUTPUT.PUT_LINE('roznica: ' || to_char(roznica));
  END IF;
EXCEPTION
  WHEN input_error_exception 
    THEN DBMS_OUTPUT.PUT_LINE('blad we wprowadzaniu daty!');
  WHEN 
    OTHERS 
  THEN
    IF SQLCODE = -1847
    THEN DBMS_OUTPUT.PUT_LINE('blad we wprowadzaniu daty!');
    END IF;
END;

--zad2
--DOKONCZYC
DECLARE
  insert_error_exception EXCEPTION;
  delete_error_exception EXCEPTION;
  przed_min number(3);
BEGIN
  INSERT INTO WYKLADOWCA(ID_WYKLADOWCA,IMIE, NAZWISKO, ID_ADRES, ID_TYTUL) VALUES(31,'Jan','Kowalski',70,1);
  IF SQL%NOTFOUND THEN 
    RAISE insert_error_exception;
  END IF;
  
  ;
  
  SELECT przed 
  into przed_min
  from
  (
    SELECT zajecia.id_przedmiot as przed, round(avg(ocena.ocena),2)
    FROM zajecia, ocena
    WHERE ocena.id_zajecia=zajecia.id_zajecia
    having round(avg(ocena.ocena),2)=
    (
      SELECT MIN(srednia)
      --into srednia_min
      FROM
      (
        SELECT ROUND(avg(ocena),2) as srednia, zajecia.id_przedmiot as przed
        FROM zajecia, ocena
        WHERE ocena.id_zajecia=zajecia.id_zajecia
        GROUP BY zajecia.id_przedmiot
      )
    )
    srednia_min
    group by zajecia.id_przedmiot
  )
    
  IF SQL%ROWCOUNT>1 THEN
    RAISE delete_error_exception;
  ELSE
    DELETE FROM przedmiot WHERE przedmiot.id_przedmiot=przed_min;
  END IF;

EXCEPTION
  WHEN insert_error_exception
  THEN DBMS_OUTPUT.PUT_LINE('blad podczas inserta!');
  
  WHEN insert_error_exception
  THEN DBMS_OUTPUT.PUT_LINE('blad podczas deleta!');

END;













