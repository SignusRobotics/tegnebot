clear all;
%Teller antall trekk som blir sendt til roboten.
trekkSendtRobotStudio = 0;
gameOn = true;
%Henter kameraforbindelse
cam = webcam(2);
% Henter bilde av brett uten brikker - enten med kamera eller med bilde 
%BrettStart = imread('12.png');
%Tar stillbilde med kamera: 
BrettStart = snapshot(cam);
%Viser bildet: 
figure;
imshow(BrettStart);
%Viser det kamera ser - brukes til kalibrering av grensene til brettrutene.  preview(cam);


%kobler opp forbindelse til robotStudio:
tcp = tcpip('192.168.125.1', 2345);
%test ip-adresse og port 
%tcp = tcpip('127.0.0.1', 2345);
fopen(tcp);


%Kalibrering av brett. Avgjør hvor på brettet roboten skal tegne.
%øvre venstre hjørne til boksen til tekstgjennkjenning, bboxes. se under.
rad1_bunnlinje = 200;
rad2_bunnlinje = 400;


kol1_hoyrelinje = 330;
kol2_hoyrelinje = 500;


%Kjøres til brett fullt. Her kunne man hatt mer kommunikasjon mellom robot
%og matlab. slik at feil spill ikke telles som ett trekk og annet.
while gameOn
    %Kan også bruke to bilder der ene er tomt brett, og I er samme brett,
    %men man tegner på skjerm og trykker lagre (ctrl s). 
    I = imread('23.png');
    %Venter i 5 sekunder: 
    pause(5);
    %For stillbilde fra kamera
    %I = snapshot(cam);
    %figure;
    %imshow(I)
    
    %Absolutte differansen mellom de to bildene. I - Brett
    BrikkeUtenBrett = imabsdiff(I,BrettStart);
    %Henter siste trekk. tekstgjenkjenningsfunksjon, ocr. Ser tegnene: O, o
    %0, x og X.
    results = ocr(BrikkeUtenBrett, 'CharacterSet', '0OoxX', 'TextLayout','Block');
    %Henter resultatet av trekket.
    brikke = results.Text;
    %Fjerner tomme tegn foran og bak (' o ' = 'o'):
    FinnTrekk=strtrim(brikke)
    
    %sammenligner resultatet med tom string. om de er samme returnerer til
    %start i whileloop:
    if strcmp(FinnTrekk, '')
        disp('Fant ikke tekst')
        pause(1);
        continue
    else
        %Skriver ut resultatet
        disp(FinnTrekk)
    end
    %label må brukes til boksene: 
    label = ['o' 'O' '0' 'x' 'X'];
    %posisjon hvor boksene skal settes. Venstre øvre hjørne for tegn som er
    %lest ut. [x,y,bredde, høyde]  
    bboxes = locateText(results,'[0OoxX]','UseRegexp', true);
    %Bokser rundt et og ett tegn:
    box = insertObjectAnnotation(BrikkeUtenBrett, 'rectangle', bboxes, label);
    %     figure;
    %     imshow(box);
    %For å ta bort støy fra små tegn som leses ut 
    if bboxes(1,3)> 30 && bboxes (1,4) > 30
        rad = bboxes(1,2); %Henter ut radverdiene i kolonne 2. forloop trengs ikke ved en og en rute, bare teste om x, y
        kol = bboxes(1,1); %Henter ut x-verdien, altså bestemmer om det er tegnet i kolonne 1:3
        %Her sjekkes hvilken rute trekket er i :
        if rad < rad1_bunnlinje %rad 1 bunnstrek % tegnet i rad 1: Finn kolonne:
            if kol< kol1_hoyrelinje
                disp(rad)
                disp(kol)
                disp('du tegnet i rute 1')
                switch FinnTrekk
                    case 'x'
                        %om sant sendes dette til roboten. Teksten inneholder
                        %rad, kolonne, tegn og rutenummer.
                        fwrite(tcp, 'x001') %'x00' Sende tre variabler istedet slik at 0 0 1 representerer rad 1 kol 1 og rute 1.
                    case 'X'
                        fwrite(tcp, 'x001')
                    case '0'
                        fwrite(tcp, 'o001')
                    case 'o'
                        fwrite(tcp, 'o001')
                    case 'O'
                        fwrite(tcp, 'o001')
                end
            elseif kol < kol2_hoyrelinje & kol > kol1_hoyrelinje
                disp(rad)
                disp(kol)
                disp('du tegnet i rute 2')
                switch FinnTrekk
                    case 'x'
                        fwrite(tcp, 'x012')
                    case 'X'
                        fwrite(tcp, 'x012')
                    case '0'
                        fwrite(tcp, 'o012')
                    case 'o'
                        fwrite(tcp, 'o012')
                    case 'O'
                        fwrite(tcp, 'o012')
                end
            elseif kol > kol2_hoyrelinje
                disp(rad)
                disp(kol)
                disp('du tegnet i rute 3')
                switch FinnTrekk
                    case 'x'
                        fwrite(tcp, 'x023')
                    case 'X'
                        fwrite(tcp, 'x023')
                    case '0'
                        fwrite(tcp, 'o023')
                    case 'o'
                        fwrite(tcp, 'o023')
                    case 'O'
                        fwrite(tcp, 'o023')
                end
            end
        elseif rad  > rad1_bunnlinje  & rad < rad2_bunnlinje
            if kol<kol1_hoyrelinje
                disp(rad)
                disp(kol)
                disp('du tegnet i rute 4')
                switch FinnTrekk
                    case 'x'
                        fwrite(tcp, 'x104')
                    case 'X'
                        fwrite(tcp, 'x104')
                    case '0'
                        fwrite(tcp, 'o104')
                    case 'o'
                        fwrite(tcp, 'o104')
                    case 'O'
                        fwrite(tcp, 'o104')
                end
                %send til robotstudio
            elseif kol <= kol2_hoyrelinje & kol > kol1_hoyrelinje
                disp(rad)
                disp(kol)
                disp('du tegnet i rute 5')
                switch FinnTrekk
                    case 'X'
                        fwrite(tcp, 'x115')
                        %disp(x5)
                    case 'x'
                        fwrite(tcp, 'x115')
                        disp('x5')
                    case '0'
                        fwrite(tcp, 'o115')
                    case 'o'
                        fwrite(tcp, 'o115')
                    case 'O'
                        fwrite(tcp, 'o115')
                end
            elseif kol >= kol2_hoyrelinje
                disp(rad)
                disp(kol)
                disp('du tegnet i rute 6')
                switch FinnTrekk
                    case 'x'
                        fwrite(tcp, 'x126')
                    case 'X'
                        fwrite(tcp, 'x126')
                    case '0'
                        fwrite(tcp, 'o126')
                    case 'o'
                        fwrite(tcp, 'o126')
                    case 'O'
                        fwrite(tcp, 'o126')
                end
            end
        elseif rad  >= rad2_bunnlinje
            if kol<kol1_hoyrelinje
                disp(rad)
                disp(kol)
                disp('du tegnet i rute 7')
                switch FinnTrekk
                    case 'x'
                        fwrite(tcp, 'x207')
                        disp(x5)
                    case 'X'
                        fwrite(tcp, 'x207')
                        disp('x5')
                    case '0'
                        fwrite(tcp, 'o207')
                    case 'o'
                        fwrite(tcp, 'o207')
                    case 'O'
                        fwrite(tcp, 'o207')
                end
                %send til robotstudio
            elseif kol <kol2_hoyrelinje & kol > kol1_hoyrelinje
                disp(rad)
                disp(kol)
                disp('du tegnet i rute 8')
                switch FinnTrekk
                    case 'x'
                        fwrite(tcp, 'x218')
                    case 'X'
                        fwrite(tcp, 'x218')
                    case '0'
                        fwrite(tcp, 'o218')
                    case 'o'
                        fwrite(tcp, 'o218')
                    case 'O'
                        fwrite(tcp, 'o218')
                end
            elseif kol >= kol2_hoyrelinje
                disp(rad)
                disp(kol)
                disp('du tegnet i rute 9')
                switch FinnTrekk
                    case 'x'
                        fwrite(tcp, 'x229')
                    case 'X'
                        fwrite(tcp, 'x229')
                    case '0'
                        fwrite(tcp, 'o229')
                    case 'o'
                        fwrite(tcp, 'o229')
                    case 'O'
                        fwrite(tcp, 'o229')
                end
            else
                disp(rad)
                disp(kol)
                disp('du bommet')
            end
        end
        %neste runde: Nyeste bilde settes til referanse - og nytt bilde tas
        %etter at det er spillt nytt trekk. se over
        BrettStart = I;
        %Teller ant trekk:
        trekkSendtRobotStudio = trekkSendtRobotStudio + 1;
        %Pause 5 sekunder:
        pause(5);
        if trekkSendtRobotStudio == 9
            %9 trekk betyr at spillebrettet er fullt
            gameOn = false;
        end
    end
end    