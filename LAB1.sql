--zad1
SELECT PRZEDMIOT.NAZWA, ROUND(AVG(OCENA.OCENA),2) AS "�REDNIA OCEN"  
FROM OCENA, PRZEDMIOT, ZAJECIA
WHERE ZAJECIA.ID_PRZEDMIOT=PRZEDMIOT.ID_PRZEDMIOT
AND ZAJECIA.ID_ZAJECIA=OCENA.ID_ZAJECIA
GROUP BY PRZEDMIOT.NAZWA;

--ZAD1 V.2
SELECT 
  PRZEDMIOT.NAZWA, 
  ROUND(AVG(OCENA.OCENA),2) AS "�REDNIA OCEN"
FROM ZAJECIA 
  RIGHT JOIN OCENA ON ZAJECIA.ID_ZAJECIA=OCENA.ID_ZAJECIA 
  LEFT JOIN PRZEDMIOT ON ZAJECIA.ID_PRZEDMIOT=PRZEDMIOT.ID_PRZEDMIOT
GROUP BY PRZEDMIOT.NAZWA;

--zad1 TEST
SELECT 
  PRZEDMIOT.NAZWA, 
  ROUND(AVG(OCENA.OCENA),2) AS "�REDNIA OCEN"
FROM ZAJECIA 
  LEFT JOIN OCENA ON ZAJECIA.ID_ZAJECIA=OCENA.ID_ZAJECIA 
  RIGHT JOIN PRZEDMIOT ON ZAJECIA.ID_PRZEDMIOT=PRZEDMIOT.ID_PRZEDMIOT
GROUP BY PRZEDMIOT.NAZWA;


--zad2
SELECT DISTINCT
  WYKLADOWCA.IMIE||' '||WYKLADOWCA.NAZWISKO AS "WYKLADOWCA",
  PRZEDMIOT.NAZWA,
  BUDYNEK.NAZWA AS BUDYNEK,
  SALA.KODSALI
FROM WYKLADOWCA, ZAJECIA, BUDYNEK, SALA, PRZEDMIOT
WHERE ZAJECIA.ID_WYKLADOWCA=WYKLADOWCA.ID_WYKLADOWCA
AND ZAJECIA.ID_SALA=SALA.ID_SALA
AND ZAJECIA.ID_PRZEDMIOT=PRZEDMIOT.ID_PRZEDMIOT
AND BUDYNEK.ID_BUDYNEK=SALA.ID_BUDYNEK
ORDER BY WYKLADOWCA, NAZWA, BUDYNEK, KODSALI;

--zad2 v.2
SELECT DISTINCT
  WYKLADOWCA.IMIE||' '||WYKLADOWCA.NAZWISKO AS "WYKLADOWCA", 
  PRZEDMIOT.NAZWA,
  BUDYNEK.NAZWA AS BUDYNEK,
  ADRES.ULICA||' ' || ADRES.NRBUDYNKU||' '|| ADRES.MIASTO AS "ADRES",
  SALA.KODSALI
FROM ZAJECIA
  LEFT JOIN PRZEDMIOT ON ZAJECIA.ID_PRZEDMIOT=PRZEDMIOT.ID_PRZEDMIOT
  LEFT JOIN WYKLADOWCA USING(ID_WYKLADOWCA)
  LEFT JOIN PRZEDMIOT ON ZAJECIA.ID_PRZEDMIOT=PRZEDMIOT.ID_PRZEDMIOT
  LEFT JOIN 
  (
    BUDYNEK 
      NATURAL LEFT JOIN ADRES
      NATURAL RIGHT JOIN SALA
  ) ON ZAJECIA.ID_SALA=SALA.ID_SALA
  ORDER BY WYKLADOWCA, NAZWA, BUDYNEK, KODSALI;
  

--zad3
SELECT 
  WYKLADOWCA.IMIE||' '||WYKLADOWCA.NAZWISKO AS "WYKLADOWCA",
  PRZEDMIOT.NAZWA,
  ROUND(AVG(OCENA.OCENA), 2) AS OCENA
FROM WYKLADOWCA, ZAJECIA, OCENA, PRZEDMIOT
WHERE 
  ZAJECIA.ID_WYKLADOWCA=WYKLADOWCA.ID_WYKLADOWCA
  AND ZAJECIA.ID_ZAJECIA=OCENA.ID_ZAJECIA
  AND ZAJECIA.ID_PRZEDMIOT=PRZEDMIOT.ID_PRZEDMIOT
GROUP BY PRZEDMIOT.NAZWA, WYKLADOWCA.IMIE||' '||WYKLADOWCA.NAZWISKO;

--ZAD3 V.2
SELECT 
  IMIE || ' ' || NAZWISKO AS WYKLADOWCA,
  NAZWA, --PRZEDMIOT.NAZWA - NATURAL JOIN WYMAGA BRAKU TAKIEGO ZAPISU
  ROUND(AVG(OCENA),2) AS OCENA
FROM ZAJECIA
  NATURAL JOIN WYKLADOWCA
  NATURAL JOIN OCENA
  NATURAL JOIN PRZEDMIOT
GROUP BY IMIE || ' ' || NAZWISKO, NAZWA;


--ZAD4

SELECT 
  PRZEDMIOT.NAZWA, 
  COUNT(OCENA) AS "LICZBA NIEZALICZONYCH",
  WYKLADOWCA.IMIE||' '||WYKLADOWCA.NAZWISKO AS WYKLADOWCA 
FROM OCENA, PRZEDMIOT, STUDENT, ZAJECIA, GRUPA, WYKLADOWCA
WHERE OCENA.OCENA<3
  AND OCENA.ID_STUDENT=STUDENT.ID_STUDENT
  AND OCENA.ID_ZAJECIA=ZAJECIA.ID_ZAJECIA
  AND ZAJECIA.ID_PRZEDMIOT=PRZEDMIOT.ID_PRZEDMIOT
  AND GRUPA.ID_GRUPA=ZAJECIA.ID_GRUPA
  AND STUDENT.ID_GRUPA=GRUPA.ID_GRUPA
  AND WYKLADOWCA.ID_WYKLADOWCA=ZAJECIA.ID_WYKLADOWCA
GROUP BY PRZEDMIOT.NAZWA, WYKLADOWCA.IMIE||' '||WYKLADOWCA.NAZWISKO
ORDER BY "LICZBA NIEZALICZONYCH" DESC;


--ZAD4 V2
--ZLE - WYSWIETLA LICZBE NIEZALICZONYCH OGOLNIE A NIE DLA KAZDEGO PRZEDMIOTU
SELECT
  PRZEDMIOT.NAZWA, 
  COUNT(STUDENT.ID_STUDENT) AS "LICZBA NIEZALICZONYCH", 
  WYKLADOWCA.IMIE||' '||WYKLADOWCA.NAZWISKO AS "WYKLADOWCA"
FROM ZAJECIA
  LEFT JOIN PRZEDMIOT USING(ID_PRZEDMIOT) -- = LEFT JOIN ZAJECIA.ID_PRZEDMIOT=PRZEDMIOT.ID_PRZEDMIOT
  LEFT JOIN WYKLADOWCA USING(ID_WYKLADOWCA)
  LEFT JOIN OCENA USING(ID_ZAJECIA)
  LEFT JOIN 
  (
    GRUPA 
      LEFT JOIN STUDENT USING(ID_GRUPA)
  ) USING (ID_GRUPA)
WHERE OCENA.OCENA<3
GROUP BY PRZEDMIOT.NAZWA, WYKLADOWCA.IMIE||' '||WYKLADOWCA.NAZWISKO
ORDER BY "LICZBA NIEZALICZONYCH" DESC;


--ZAD5
SELECT 
  WYKLADOWCA.IMIE, 
  WYKLADOWCA.NAZWISKO,
  COUNT(ZAJECIA.ID_PRZEDMIOT) AS LICZBA_PRZEDMIOTOW
FROM WYKLADOWCA, ZAJECIA, PRZEDMIOT
WHERE 
  WYKLADOWCA.ID_WYKLADOWCA=ZAJECIA.ID_WYKLADOWCA
  AND PRZEDMIOT.ID_PRZEDMIOT=ZAJECIA.ID_PRZEDMIOT
GROUP BY WYKLADOWCA.IMIE, WYKLADOWCA.NAZWISKO
ORDER BY LICZBA_PRZEDMIOTOW DESC
FETCH FIRST ROW ONLY;

--ZAD5 2 SPOSOB Z PODZAPYTANIEM

--ZAD6
SELECT 
  STUDENT.NAZWISKO,
  STUDENT.IMIE, 
  GRUPA.NAZWA, 
  KIERUNEK.NAZWA
FROM GRUPA
  LEFT JOIN KIERUNEK USING(ID_KIERUNEK)
  RIGHT JOIN STUDENT USING(ID_GRUPA)
  ORDER BY STUDENT.NAZWISKO, STUDENT.IMIE ASC;
  
  
--ZAD7

--TODO

--ZAD8
SELECT NAZWA, COUNT(ZAJECIA.ID_ZAJECIA) AS ILOSC_GODZIN
FROM PRZEDMIOT
LEFT JOIN ZAJECIA USING(ID_PRZEDMIOT)
GROUP BY NAZWA
HAVING 
   COUNT(ZAJECIA.ID_ZAJECIA)=
   (
     SELECT MAX(A.GODZINY)
     FROM 
       (
          SELECT COUNT(ZAJECIA.ID_ZAJECIA) AS GODZINY
          FROM PRZEDMIOT
          LEFT JOIN ZAJECIA USING(ID_PRZEDMIOT)
          GROUP BY NAZWA        
        ) A
   );
      
      
  
--ZAD8 WERSJA PROSTA, ALE NIE DO KONCA POPRAWNA 
SELECT 
  PRZEDMIOT.NAZWA, COUNT(ZAJECIA.ID_ZAJECIA) AS GODZINY
FROM PRZEDMIOT
LEFT JOIN ZAJECIA USING(ID_PRZEDMIOT)
GROUP BY PRZEDMIOT.NAZWA
ORDER BY GODZINY DESC
FETCH FIRST ROW ONLY;

--ZAD9
SELECT STUDENT.IMIE, STUDENT.NAZWISKO, ADRES.MIASTO
FROM STUDENT LEFT JOIN ADRES USING(ID_ADRES)
ORDER BY MIASTO, STUDENT.NAZWISKO, STUDENT.IMIE DESC;

--ZAD10
SELECT DISTINCT 
  WYKLADOWCA.IMIE || ' ' ||WYKLADOWCA.NAZWISKO AS WYKLADOWCA, 
  PRZEDMIOT.NAZWA, 
  TYTULNAUKOWY.NAZWA,
  MAX(OCENA.OCENA)
FROM ZAJECIA 
LEFT JOIN PRZEDMIOT USING(ID_PRZEDMIOT) 
LEFT JOIN OCENA USING(ID_ZAJECIA)
LEFT JOIN 
(
  WYKLADOWCA LEFT JOIN TYTULNAUKOWY USING(ID_TYTUL)
) USING(ID_WYKLADOWCA)
WHERE TYTULNAUKOWY.NAZWA LIKE 'dr in�.'
GROUP BY WYKLADOWCA.IMIE || ' ' ||WYKLADOWCA.NAZWISKO, PRZEDMIOT.NAZWA, TYTULNAUKOWY.NAZWA;

--ZAD11
SELECT DISTINCT STUDENT.IMIE, STUDENT.NAZWISKO, PRZEDMIOT.NAZWA
FROM ZAJECIA
LEFT JOIN PRZEDMIOT USING(ID_PRZEDMIOT)
LEFT JOIN 
(
  STUDENT 
    LEFT JOIN GRUPA USING(ID_GRUPA)
    LEFT JOIN OCENA USING(ID_STUDENT) 
) USING(ID_GRUPA)
WHERE OCENA.OCENA>=3;    
  
  
  
  
  
  
  
  
  
  
  
  
