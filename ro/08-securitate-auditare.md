# Capitolul 8: Securitatea și Auditarea Smart Contracts

## Introducere

Capitol acesta acoperă tipare de vulnerabilități, metodologii de evaluare a riscurilor și cele mai bune practici pentru întărirea securității la smart contracts. De asemenea, vom discuta și rolul auditului în minimizarea nevoii de încredere creșterea rezilienței protocoalelor.

### Subiecte Acoperite

- Securitatea în Ecosistemul Blockchain
- Vulnerabilități Comune în Smart Contracts
- Evaluarea Riscurilor Vulnerabilităților
- Cele Mai Bune Practici de Securitate
- Auditarea Smart Contracts
- Securitatea Blockchain Astăzi

### Cerințe Preliminare

- Cunoștințe de Solidity
- Înțelegerea conceptelor de testare
- Cunoștințe de bază despre DeFi (ex: ERC20)
- Abilitatea de a plânge în tăcere

## Securitatea în Ecosistemul Blockchain

Securitatea înseamnă protecție împotriva sau rezistență la potențiale, daune.

Ecosistemul Blockchain are nevoie de securitate și protecție din două motive principale:

- Blockchain-ul nu necesită permisiuni pentru a interacționa cu el, este "permisionless" → oricine poate crea orice
- Orice poate primi o valoare financiară → totul poate deveni FinTech (Financial Technology)

Cum ar trebui să ne gândim la tehnologia Blockchain:

- MCaaS - Manufacturing Cars as a Service (Fabricarea de Mașini ca Serviciu)
- BaaS - Banks as a Service (Bănci ca Serviciu)
- BRaaS - Brokerage as a Service (Brokeraj ca Serviciu)
- CaaS - Casinos as a Service (Cazinouri ca Serviciu)

În toate aceste interpretări, pentru ca o companie să lanseze un astfel de produs, ar avea nevoie de un audit: financiar, software sau de securitate cybernetică. Nu poți pur și simplu să creezi o bancă.

Deși în ecosistemul blockchain oricine poate crea orice, trebuie acordată o atenție deosebită securității pentru a evita pierderile financiare.

## Vulnerabilități Comune în Smart Contracte

De-a lungul anilor, au fost identificate mai multe tipuri de probleme în lumea Blockchain, ceea ce a dus la o clasificare largă și neuniformă a vulnerabilităților. Aceasta este încă situația curentă.

A existat o tentativă de a crea un standard numit Clasificarea Slăbiciunilor a Smart Contracts (Smart Contract Weakness Classification, SWC), dar [a fost abandonat în 2020](https://swcregistry.io/).

Clasificări de vulnerabilități relevante și acceptate în general:

- `Limitarea Accesului (Access Control)`: funcții critice care ar trebui să fie accesate doar de entități privilegiate sunt lăsate accesibile oricui.
- `Lipsă de Validare a Datelor de Intrare (Lack of Input Validation)`: datele introduse de utilizator nu sunt verificate, permițând comportamente neașteptate.
- `Configurare Greșită (Misconfiguration)`: variabile critice ale contractului sunt setate incorect.
- `Dependință de Preț Inadecvată (Inadequate Price Dependency)`: calculul prețului tokenului se bazează pe o sursă care poate fi manipulată.
- `Pierderea Preciziei (Precision Loss)`: erorile de rotunjire cauzate de împărțiri pot duce la comportamente neașteptate.
- `Reentranță (Reentrancy)`: contractul poate fi apelat din nou înainte ca execuția anterioară să se finalizeze, ducând la inconsistențe de stare.
- `Greșală de Logică (Logic Bug)`: logica principală a contractului nu este implementată conform specificațiilor și intențiilor protocolului.

### Exerciții

Pentru a înțelege mai bine cum atacatorii exploatează vulnerabilitățile pentru a compromite proiecte, participanții au 2 exerciții în care trebuie să adopte mentalitatea unui atacator și să exploateze un contract fictiv. Gândirea ca un atacator ajută la înțelegerea metodelor de apărare. Tipul ăsta de gândire este cunoscută ca programare defensivă.

Soluțiile exercițiilor pot fi găsite în [slide-urile PDF însoțitoare](../en/resources/08-security-auditing/ETH-Cluj-2025-Security-Workshop.pdf).

#### Exercițiul #1 - Kingdom

**Descriere**: Într-un tărâm îndepărtat, conducerea a decis să recompenseze cei mai loiali supuși. Un contract `Treasury` a fost implementat și monede de aur au fost adăugate pentru ca fiecare supus să le revendice. Un supus furios, omis din lista de recompense, devine atacator și vrea să fure cât mai multe monede.

**Sarcină**: În funcția `Kingdom.t.sol::stealGoldCoins`, implementează ce este necesar pentru ca atacatorul să obțină la final 56 de monede de aur.

_Nu ai voie să folosești VM cheat codes_

Repo: https://github.com/abarbatei/Kingdom-E4E-ETHCluj-2025/tree/main

#### Exercițiul #2 - TooEasyBox

**Descriere**: Contractul `TooEasyBox` este folosit pentru a stoca pachete (ETH) pentru utilizatori. Curierul plasează fonduri pentru fiecare, urmând ca utilizatorii să le retragă. Un atacator observă că sunt multe pachete (ETH) în contract și încearcă să le fure pe toate.

**Sarcină**: În funcția `Playground.t.sol::hackerGonnaHack`, implementează ce este necesar pentru ca atacatorul să fure tot ETH-ul din `TooEasyBox`.

_Nu ai voie să folosești VM cheat codes_

Repo: https://github.com/abarbatei/TooEasyBox-E4E-ETHCluj-2025/tree/main

### Reentrancy

Al doilea exercițiu evidențiază o problemă clasică de tip reentrancy. Totuși, problemele de reentrancy pot fi mai complexe și nuanțate:

- `Reentrancy Clasic (Classical)`: reapelarea aceleiași funcții în cadrul aceluiași contract
- `Reentrancy între Funcții (Cross-function)`: reapelarea unei funcții diferite care are starea comună cu funcția vulnerabilă
- `Reentrancy între Contracte (Cross-contract)`: reapelarea are loc între mai multe contracte într-un sistem sau protocol
- `Reentrancy între Blockchains`: reentrancy între mai multe blockchains în timpul apelurilor asincrone ale mecanismelor te transmitere a acțiunilor, poduri (bridges)
- `Reentrancy de Citire (Read-only/View)`: reentrancy prin funcții view sau pure, care nu alterează starea contractului și care influențează citiri off-chain sau logica condițională din alte contracte

Este important de menționat că toate tipurile de vulnerabilități menționate anterior au mai multe variații și ramificații, fiecare cu grade diferite de severitate. Ca dezvoltator, trebuie să fii conștient de ele la un nivel minim pentru a le putea preveni.

## Evaluarea Riscurilor Vulnerabilităților

Vulnerabilitățile introduc probleme, iar fiecare problemă are un anumit grad de risc de securitate. Riscul este evaluat în funcție de **cât de severă este o problemă**.

În funcție de probabilitatea apariției și impactul său, o problemă este clasificată într-una din patru categorii de risc sau severitate: 🔴Critic, 🟠Ridicat, 🟡Mediu, 🟢Scăzut sau 🔵Informațional/Calitatea-codului.

|      Severitate        | Impact: Ridicat | Impact: Mediu | Impact: Scăzut |
|:-----------------------|:----------------|:--------------|:----------------|
|  Probabilitate: Ridicată | 🔴Critic       |  🟠Ridicat   | 🟡Mediu         |
| Probabilitate: Medie    | 🟠Ridicat       |  🟡Mediu     | 🟢Scăzut        |
|  Probabilitate: Scăzută | 🟡Mediu         |  🟢Scăzut    | 🟢Scăzut        |

### Impact

- **Ridicat** - duce la o pierdere semnificativă de fonduri în cadrul protocolului sau afectează grav un grup de utilizatori.
- **Mediu** - doar o sumă mică de fonduri poate fi pierdută sau o funcționalitate a protocolului este afectată.
- **Scăzut** - comportament neașteptat care nu este critic.

### Probabilitate

- **Ridicată** - vector de atac direct; costul este relativ mic comparativ cu suma care poate fi pierdută.
- **Medie** - vector de atac condiționat, dar încă relativ probabil.
- **Scăzută** - presupuneri prea multe sau improbabile; oferă puțin sau deloc stimulente pentru atacator.

### Acțiuni necesare în funcție de nivelul de severitate

- 🔴**Critic** – problema **trebuie** remediată
- 🟠**Ridicat** – problema **trebuie** remediată
- 🟡**Mediu** – problema **ar trebui** remediată
- 🟢**Scăzut** – problema **ar putea** fi remediată

### Probleme Informaționale

Problemele informaționale includ recomandări pentru îmbunătățirea calității codului, alinierea la bune practici din industrie, optimizări de execuție, conformitatea cu standardele și îmbunătățirea designului general al contractului.

De obicei, acestea nu au un impact semnificativ asupra funcționalității sau riscului de securitate.

Este important să se evalueze toate tipurile de vulnerabilități, inclusiv cele informaționale, pentru a asigura securitatea și fiabilitatea proiectului.

### Chestionar privind Pierderea de Fonduri

Următorul chestionar este folosit pentru a discuta cum evaluăm impactul în cazul pierderii de fonduri:

Cum ai evalua impactul (niciunul, scăzut, mediu, ridicat, nu se poate determina) în următoarele situații?

- Un utilizator pierde $50
- Un utilizator pierde $50 dintr-o sumă de $500
- Un utilizator pierde $50 dintr-o sumă de $5.000.000
- Un utilizator pierde $50 pe an
- Un utilizator pierde $50 pe an dintr-o sumă de $500
- Un utilizator pierde $50 pe an dintr-o sumă de $5.000.000
- Un utilizator pierde $50 pe zi
- Un utilizator pierde $50 pe zi dintr-o sumă de $500
- Un utilizator pierde $50 pe zi dintr-o sumă de $5.000.000
- Un utilizator suferă un furt de $50
- Un utilizator suferă un furt de $50 dintr-o sumă de $500
- Un utilizator suferă un furt de $50 dintr-o sumă de $5.000.000
- Un utilizator pierde $50 din cauza unei erori de rotunjire
- Un utilizator pierde $50 din cauza unei erori de rotunjire dintr-o sumă de $500
- Un utilizator pierde $50 din cauza unei erori de rotunjire dintr-o sumă de $5.000.000

Soluțiile pot fi găsite în [slide-urile PDF însoțitoare](../en/resources/08-security-auditing/ETH-Cluj-2025-Security-Workshop.pdf).

#### Concluzii privind Evaluarea Severității

- Evaluarea impactului în caz de pierdere de fonduri depinde de procentul pierdut din toată suma inițailă de către victimă și de modul în care aceasta pierdere a avut loc.
- Timp nu influențează impactul, influențează severitatea.
- Furtul are întotdeauna impact ridicat.
- Erorile de rotunjire pot avea impact de la scăzut la ridicat, în funcție de procentul pierdut.
- Șabloanele pentru determinarea severității sunt subiective și pot varia. Exemple:
  - Sherlock definește [pierdere semnificativă](https://docs.sherlock.xyz/audits/judging/guidelines): `utilizatorii pierd mai mult de 1% și mai mult de $10 din suma lor`
  - Immunefi definește [furtul direct de fonduri ca severitate critică](https://immunefi.com/immunefi-vulnerability-severity-classification-system-v2-3/) (indiferent de probabilitate)

## Cele Mai Bune Practici de Securitate

Următoarea înșiruire este o listă (incompletă) de bune practici în dezvoltarea oricărui protocol:

- Limitează cât mai mult acțiunile utilizatorilor
  - Acțiuni de tipul _acționează în numele altora_ pot introduce probleme
  - Dacă un utilizator nu are niciun motiv să apeleze o funcție, nu o fă accesibilă lui
- Mută cât mai multă logică în afara blockchain-ului (off-chain)
  - Ex: dacă un contract are nevoie de o listă sortată, validează că lista introdusă de utilizator este sortată, nu o sorta on-chain
- Validează întotdeauna datele de intrare introduse de către utilizatori (și cel al protocolului)
- Gândește mai întâi pe "happy path" (fluxul de execuție cel mai des folosit de către utilizatorii proiectului), apoi cazuri limită
  - Ex: cum se comportă protocolul în situații de volatilitate extremă?
- Fiecare împărțire poate genera eroare de rotunjire trebuie examinată și setată în favoarea protocolului
- Dacă se acceptă tokenuri cu zecimale diferite, menționează și notează, clar, zecimalele fiecărei variabile
- Verifică fiecare scădere pentru posibile underflow-uri
- Convertește scăderile în adunări acolo unde este posibil. Exemplu:

|                  | Exemplu Cod                              |
|------------------|-------------------------------------------|
| **În loc de**    | `currentTime - duration > startTime`      |
| **Folosește**    | `currentTime > startTime + duration`      |

- Folosește întotdeauna librării de cod "safe" pentru operațiuni, dacă există
  - Ex: [`safeCasting`](https://docs.openzeppelin.com/contracts/5.x/api/utils#SafeCast), [`safeTransfer`](https://docs.openzeppelin.com/contracts/5.x/api/token/erc20#SafeERC20), [`forceApprove`](https://docs.openzeppelin.com/contracts/5.x/api/token/erc20#SafeERC20-forceApprove-contract-IERC20-address-uint256-)
- Reutilizează cod din librării auditate pe cât posibil
  - Ex: OpenZeppelin, Solady, Solmate
- Integrarea cu sisteme externe reprezintă puncte slabe. Trebuie să cunoști în detaliu dependențele pe care le folosești
  - Ex: la integrarea cu DEX-uri, trebuie alese slippage și deadline-uri
- Urmează [ghidul oficial de stil Solidity](https://docs.soliditylang.org/en/latest/style-guide.html). Cod bine organizat ajută la identificarea mai ușoară a problemelor
- Păstrează codul cât mai simplu și scurt
- Gândește mereu ca un atacator
  - Identifică fiecare invariant al protocolului și încearcă să-l abuzezi
  - Vezi dacă asta poate cauza daune protocolului
- Testare
  - Testele trebuie să aibe 100% acoperire
  - Adaugă teste fuzz și teste pe invarianți
  - Verifică formal codul
- Evită securitatea prin obscuritate pentru că nu funcționează. Cel mult poate doar amâna un hack, dar și descoperirea de către un whitehat
- Verifică toate listele de "potențial probleme existnente" pentru specifice tipului tău de protocol. Exemple:
  - https://docs.soliditylang.org/en/latest/security-considerations.html
  - https://solodit.cyfrin.io/checklist
  - https://scsfg.io/developers/
  - https://dacian.me/defi-liquidation-vulnerabilities
- Auditează componentele on-chain și off-chain

## Auditarea a Smart Contracts

Auditarea la smart contracts este procesul de revizuire și analiză a codului unui smart contract pentru a identifica vulnerabilități, probleme de securitate sau greșeli potențiale.

O variație a celebrului citat al lui E.W. Dijkstra despre testare descrie perfect auditarea smart contractelor:

"Auditarea smart contractelor poate demonstra prezența greșelilor, dar niciodată absența lor"

<table>
<tr>
<td>

Un auditor de smart contracte:
- Revizuiește codul pentru a identifica probleme
- Creează teste de tip proof-of-concept (POC) pentru a demonstra problemele
- Propune soluții
- Se asigură că soluțiile sunt implementate corect
- Compilează toate problemele, sugestiile și soluțiile într-un raport oferit clientului

</td>
<td>

<img src="../en/resources/08-security-auditing/auditor-flow.PNG" alt="auditor-flow" width="90"/>

</td>
</tr>
</table>

Ideal, un proiect trece prin mai multe audite și tipuri de audite. Dacă sunt descoperite probleme relevante, ciclul de auditare trebuie reluat.

![auditor-flow](../en/resources/08-security-auditing/ideal-protocol-audit-loop.PNG)

## Securitatea Blockchain Astăzi

În prezent, eforturile din ecosistemul de securitate blockchain se împart în patru mari categorii:

- Conținut Educațional
- Securitate Crowdsourced
- Automatizări de Securitate
- Verificare și Testare Avansată

### Conținut Educațional

Conținutul educațional în domeniul securității a crescut treptat gradul de conștientizare și reziliența pieței. Este esențial pentru menținerea unor standarde ridicate.

Surse relevante:

- https://updraft.cyfrin.io/courses 
- https://www.rareskills.io/ 
- https://www.youtube.com/@0xOwenThurm 
- https://dacian.me/ 
- https://x.com/RealJohnnyTime 
- https://www.youtube.com/@PatrickAlphaC 
- https://newsletter.blockthreat.io/

### Securitate Crowdsourced

Securitate Crowdsourced este reprezentată de concursuri de audit sau competiții tip bug bounty.

Un concurs de audit este o revizuire de cod descentralizată, limitată în timp, unde proiectele oferă un pot de recompense distribuit între auditori în funcție de rapoartele trimise. Diferă de bug bounty-urile clasice prin faptul că au o limită de timp cât timp sunt active (timeboxed).

Un avantaj important: nu există barieră de intrare, oricine poate participa.

Platforme relevante:

- https://immunefi.com/
- https://cantina.xyz/
- https://sherlock.xyz/
- https://code4rena.com/
- https://codehawks.com/
- https://hackenproof.com/
- https://hats.finance/

### Automatizări de Securitate

Instrumente și tehnologii actuale includ:

- analizatori statici (ex: slither, lightChaser, 4naly3er, aderyn)
- agenți AI (ex: AuditAgent, Savant)
- orchestratoarea uneltelor de securitate (ex: Magnus)

Resurse utile:

- https://www.lightchaser.online/
- https://auditagent.nethermind.io/
- https://immunefi.com/blog/all/introducing-magnus/
- https://savant.chat/
- https://github.com/crytic/slither
- https://github.com/Picodes/4naly3er
- https://github.com/Cyfrin/aderyn/tree/dev

### Verificare și Testare Avansată

Se face prin:
- verificare formală
- testare fuzz

Ambele proceduri sunt esențiale pentru detectarea vulnerabilităților și sunt în continuă dezvoltare pe piață.

Exemple de unelte (tools):

- https://getrecon.xyz/
- https://github.com/Certora/CertoraProver
- https://runtimeverification.com/#tools-section
- https://github.com/crytic/medusa
- https://github.com/a16z/halmos
- https://github.com/crytic/echidna/tree/master

## Concluzie

- Securitatea este esențială pentru tehnologia blockchain din cauza naturii sale financiare
- Securitatea blockchain este un domeniu nou și încă nereglementat complet
- Cele mai multe vulnerabilități sunt cunoscute, dar nu sunt conștientizate de dezvoltatori, de aici nevoia de audituri multiple
- Urmarea bunelor practici reduce semnificativ șansele unui hack
- Auditarea smart contractelor va continua să existe atâta timp cât există tehnologia blockchain publică

## Referințe

- https://swcregistry.io/
- https://drive.google.com/file/d/1Cx1vCTv7v-U_ICDinE9W2JwjQULMepCn/view
- https://blog.chainlight.io/web3-hack-postmortem-2024-2b8ed0116c93
- https://docs.sherlock.xyz/audits/judging/guidelines
- https://immunefi.com/immunefi-vulnerability-severity-classification-system-v2-3/
- https://docs.openzeppelin.com/contracts/5.x/api/token/erc20#SafeERC20
- https://docs.soliditylang.org/en/latest/style-guide.html
- https://scottschober.com/bug-bounties-created-equal/
- https://docs.soliditylang.org/en/latest/security-considerations.html
- https://solodit.cyfrin.io/checklist
- https://scsfg.io/developers/
- https://dacian.me/defi-liquidation-vulnerabilities