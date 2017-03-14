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

/**ZAD 5**/
ACCEPT n prompt 'Podaj n';
DECLARE
  N_VAL NUMBER(3):= &n;
  RESULT_VAL NUMBER (12,4):=0;
  SILNIA_VAL INT:=0;
BEGIN
  FOR iter IN 0.. N_VAL LOOP
  
        CASE
          WHEN N_VAL<0 THEN
            DBMS_OUTPUT.PUT_LINE('LICZBA UJEMNA');
          WHEN N_VAL = 0 THEN
            SILNIA_VAL := 1;
          ELSE
            SILNIA_VAL:=1;
            FOR iter2 IN 1..iter LOOP
              SILNIA_VAL := SILNIA_VAL * iter2;
            END LOOP;
          END CASE;
          
    RESULT_VAL:=RESULT_VAL + 1/SILNIA_VAL;
  END LOOP;
   DBMS_OUTPUT.PUT_LINE('wynik: ' || RESULT_VAL);
END;
