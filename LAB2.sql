SET SERVEROUTPUT ON

--zad1
ACCEPT input_imie prompt 'wprowadz imie';
ACCEPT input_nazwisko prompt 'wprowadz nazwisko';
DECLARE
  imie varchar2(20);
  nazwisko varchar2(20);
BEGIN
  imie:='&input_imie';
  nazwisko:='&input_nazwisko';
  DBMS_OUTPUT.PUT_LINE('Witaj' || ' ' || imie || ' ' || nazwisko);
END;

--zad2
ACCEPT input_silnia PROMPT 'wprowadz liczbe do policzenia silnii';
DECLARE
  ii NUMBER(10);
  nn NUMBER(10);
  wynik NUMBER(10):=1;
BEGIN
  nn:=&input_silnia;
  CASE
      WHEN nn=0 THEN wynik:=1;
      WHEN nn=1 THEN wynik:=1;
    ELSE
      FOR ii IN 1..nn LOOP
        wynik:=wynik*ii;  
      END LOOP;
  END CASE;
  DBMS_OUTPUT.PUT_LINE('wynik: ');
  DBMS_OUTPUT.PUT_LINE(wynik);
END;

--zad3
ACCEPT input_promien PROMPT 'wprowadz liczbe do polizenia pola i obwodu kola';
DECLARE
  promien NUMBER(5, 4);
  obwod NUMBER (5,4);
  pole NUMBER(5,4);
  pi CONSTANT NUMBER(5,4) := 3.1415;
BEGIN
  promien:=&input_promien;
  obwod:=2*pi*promien;
  pole:=pi*promien*promien;
  DBMS_OUTPUT.PUT_LINE('obwod: ' || obwod || ' pole: ' || pole);
END;

--zad4:
ACCEPT input_x PROMPT 'wprowadz podstawe';
ACCEPT input_nn PROMPT 'wprowadz wykladnik';
DECLARE
  x NUMBER(10,5);
  nn number(2);
  wynik number(10);
BEGIN
  x:=&input_x;
  nn:=&input_nn;
  
  IF x<1 OR x>10
    THEN DBMS_OUTPUT.PUT_LINE('x out of range! ');
  ELSIF nn<1 OR nn>10
    THEN DBMS_OUTPUT.PUT_LINE('nn out of range! ');
  ELSE
    wynik:=x;
    FOR iter IN 2..nn LOOP
        wynik:= wynik * x;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('wynik: ' || wynik);
  END IF;
END;

--ZAD5
ACCEPT input_nn PROMPT 'Podaj liczbe wyrazow szeregu: ';
DECLARE
  nn NUMBER(2);
  res NUMBER(10,8):=0;
  factorial_res NUMBER(10,0):=1; 
BEGIN
  nn:=&input_nn;
  FOR ii IN 0..NN LOOP
    factorial_res:=1;
    FOR jj IN 1..ii LOOP
      factorial_res:=factorial_res*jj;
    END LOOP;
    res:=res+1/factorial_res;
  END LOOP;
  dbms_output.put_line('Liczba e wynosi: '||to_char(res));
END;

--zad6

DECLARE
  time1 timestamp;
BEGIN
  LOOP
      SELECT CURRENT_TIMESTAMP
      INTO time1
      FROM dual;
  EXIT WHEN REMAINDER(round(extract(second from time1)),15)=0;
  END LOOP;
  
  DBMS_OUTPUT.PUT_LINE('jest godzina '|| to_char(time1, 'HH:MI:SS') ||' koncze dzialanie');
END;
--mod - wynik dzielenia modulo
--remainder - reszta z dzielenia modulo

--zad7
DECLARE
  srednia number(10,5); 
  student2 STUDENT%ROWTYPE;
BEGIN      
   SELECT imie, nazwisko, nralbumu, round(avg(ocena),2) AS OCENA  
   INTO student2.imie, student2.nazwisko, student2.nralbumu, srednia 
   FROM student INNER JOIN OCENA USING(ID_STUDENT)
   GROUP BY imie, nazwisko, nralbumu, id_student
   ORDER BY OCENA DESC
   FETCH FIRST ROW ONLY;
   
   SYS.DBMS_OUTPUT.PUT_LINE(student2.imie ||' ' ||student2.nazwisko||' '||student2.nralbumu||''||srednia);
END;

--zad8a
DECLARE
  student2 STUDENT%ROWTYPE;
BEGIN
  SELECT ID_STUDENT, imie, nazwisko, nralbumu 
  INTO student2.id_student, student2.imie, student2.nazwisko, student2.nralbumu
  FROM 
  (
     SELECT ID_STUDENT, imie, nazwisko, nralbumu, round(avg(ocena),2) AS OCENA  
     FROM student INNER JOIN OCENA USING(ID_STUDENT)
     GROUP BY imie, nazwisko, nralbumu, id_student
     ORDER BY OCENA ASC
     FETCH FIRST ROW ONLY
  );
END;

--zad8b
DECLARE
  TYPE student_typ IS RECORD
  (
    ID_STUDENT NUMBER(4,0),
    IMIE VARCHAR2(20),
    NAZWISKO VARCHAR2(30),
    ID_ADRES NUMBER(4,0),
    NRALBUMU NUMBER (10,0),
    ID_GRUPA NUMBER(4,0)
  );
  student2 student_typ;
BEGIN
  SELECT ID_STUDENT, imie, nazwisko, nralbumu 
  INTO student2.id_student, student2.imie, student2.nazwisko, student2.nralbumu
  FROM 
  (
     SELECT ID_STUDENT, imie, nazwisko, nralbumu, round(avg(ocena),2) AS OCENA  
     FROM student INNER JOIN OCENA USING(ID_STUDENT)
     GROUP BY imie, nazwisko, nralbumu, id_student
     ORDER BY OCENA ASC
     FETCH FIRST ROW ONLY
  );
END;
