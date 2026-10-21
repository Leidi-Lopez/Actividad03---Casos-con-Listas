% ==========================================
% ACTIVIDAD 05 - ESTRUCTURAS Y LISTAS EN PROLOG
% ==========================================

/* --- 1. EJERCICIO DE LA FAMILIA SIMPSON --- */
% Estructura: familia([ persona(Nombre, [Padres], [Hijos]), ... ])

familia([
    persona(abraham, [], [herbert, homero]),
    persona(mona, [], [herbert, homero]),
    persona(clancy, [], [marge, patty, selma]),
    persona(jacqueline, [], [marge, patty, selma]),
    persona(herbert, [abraham, mona], []),
    persona(homero, [abraham, mona], [bart, lisa, maggie]),
    persona(marge, [clancy, jacqueline], [bart, lisa, maggie]),
    persona(patty, [clancy, jacqueline], []),
    persona(selma, [clancy, jacqueline], [ling]),
    persona(bart, [homero, marge], []),
    persona(lisa, [homero, marge], []),
    persona(maggie, [homero, marge], []),
    persona(ling, [selma], [])
]).

% Reglas auxiliares sobre la lista de estructuras
obtener_persona(Nombre, Padres, Hijos) :-
    familia(Fam),
    member(persona(Nombre, Padres, Hijos), Fam).

es_padre(P, H) :-
    obtener_persona(H, Padres, _),
    member(P, Padres).

es_madre(M, H) :-
    obtener_persona(H, Padres, _),
    member(M, Padres).

hermanos(X, Y) :-
    obtener_persona(X, PadresX, _),
    obtener_persona(Y, PadresY, _),
    PadresX \== [],
    PadresX == PadresY,
    X \= Y.

abuelo(X, Y) :-
    es_padre(X, Z),
    (es_padre(Z, Y) ; es_madre(Z, Y)).

abuela(X, Y) :-
    es_madre(X, Z),
    (es_padre(Z, Y) ; es_madre(Z, Y)).

tio(X, Y) :-
    hermanos(X, Z),
    (es_padre(Z, Y) ; es_madre(Z, Y)).

primos(X, Y) :-
    es_padre(P1, X), es_padre(P2, Y), hermanos(P1, P2), X \= Y.
primos(X, Y) :-
    es_padre(P1, X), es_madre(M2, Y), hermanos(P1, M2), X \= Y.
primos(X, Y) :-
    es_madre(M1, X), es_padre(P2, Y), hermanos(M1, P2), X \= Y.
primos(X, Y) :-
    es_madre(M1, X), es_madre(M2, Y), hermanos(M1, M2), X \= Y.

sobrino(X, Y) :-
    hermanos(P, Y), es_padre(P, X).
sobrino(X, Y) :-
    hermanos(M, Y), es_madre(M, X).


/* --- 2. EJERCICIO DE CIUDADES DE CANADÁ --- */
% Estructura: grafo_canada([ nodo(Ciudad, [conexion(Destino, Costo), ...]), ... ])

grafo_canada([
    nodo(vancouver, [conexion(edmonton, 16), conexion(calgary, 13)]),
    nodo(edmonton, [conexion(saskatoon, 12)]),
    nodo(calgary, [conexion(edmonton, 4), conexion(regina, 14)]),
    nodo(saskatoon, [conexion(calgary, 9), conexion(winnipeg, 20)]),
    nodo(regina, [conexion(saskatoon, 7), conexion(winnipeg, 4)]),
    nodo(winnipeg, [])
]).

arista_lista(X, Y, Costo) :-
    grafo_canada(Grafo),
    member(nodo(X, Conexiones), Grafo),
    member(conexion(Y, Costo), Conexiones).

tiene_aristas(Nodo) :-
    grafo_canada(Grafo),
    ( member(nodo(Nodo, Conexiones), Grafo), Conexiones \= [] 
    ; member(nodo(_, ConexionesOtras), Grafo), member(conexion(Nodo, _), ConexionesOtras) ).

conexiones_con_costo(Nodo, Lista) :-
    grafo_canada(Grafo),
    member(nodo(Nodo, Conexiones), Grafo),
    transformar_conexiones(Conexiones, Lista).

transformar_conexiones([], []).
transformar_conexiones([conexion(Destino, Costo)|Resto], [[Destino, Costo]|RestoTransformado]) :-
    transformar_conexiones(Resto, RestoTransformado).

costo_por(X, Y, Z, CostoTotal) :-
    arista_lista(X, Y, Costo1),
    arista_lista(Y, Z, Costo2),
    CostoTotal is Costo1 + Costo2.

camino_dirigido(Origen, Destino, Camino) :-
    camino_dirigido_aux(Origen, Destino, [Origen], Camino).

camino_dirigido_aux(Destino, Destino, Visitados, Camino) :-
    reverse(Visitados, Camino).
camino_dirigido_aux(Actual, Destino, Visitados, Camino) :-
    arista_lista(Actual, Siguiente, _),
    \+ member(Siguiente, Visitados),
    camino_dirigido_aux(Siguiente, Destino, [Siguiente | Visitados], Camino).

costo_camino_dirigido([], 0).
costo_camino_dirigido([A, B | Resto], Costo) :-
    arista_lista(A, B, C),
    costo_camino_dirigido([B|Resto], CostoResto),
    Costo is C + CostoResto.

es_posible_viajar(Origen, Destino) :-
    camino_dirigido(Origen, Destino, _).