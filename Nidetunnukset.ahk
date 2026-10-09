; Nidetunnus-apuri © 2026 by Toni Tonteri is licensed under CC BY-NC-SA 4.0. To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/4.0/
; TESTIRIVI

#Requires AutoHotkey v2.0

;Tehdään hätästop painamalla Esc-näppäintä
Esc::
{
	MsgBox "Painoit 'HÄTÄSEIS'-nappia, prosessi on nyt keskeytetty."
	ExitApp
}

; Tehdään seuraavaksi alkuvalikko
MyGui := Gui()
MyGui.Add("Text",, "Syötä ensimmäinen nidetunnus tähän:")
MyGui.Add("Edit", "w200 vNidetunnus")
MyGui.Add("Text",, "Syötä tarrojen kokonaismäärä tähän:")
MyGui.Add("Edit", "w200 vTarramaara")
MyGui.Add("Text",, "HOX! Suljettuasi tämän ruudun,`nvalitse auki olevan ensimmäisen`nniteen tiedoista kohta 'Nidetunnus:'`nja paina sitten a-kirjainta, niin ohjelma`nalkaa laittaa nidetunnuksia paikoilleen.`nÄlä koske tietokoneeseen, ennenkuin`nohjelma ilmoittaa olevansa valmis.`nJos ilmenee tarve pysäyttää ohjelma`nkesken suorituksen, paina Esc-näppäintä.`n")
MyGui.Add("Text",, "HÄTÄSEIS-NAPPI: ESC`n")
MyGui.Add("Text",, "Valitse jompikumpi tilanteen mukaan:")
MyGui.Add("Radio", "Checked veiTulostettu", "Tarroja EI OLE tulostettu")
MyGui.Add("Radio", "vonTulostettu", "Tarrat ON tulostettu")
MyGui.Add("Text",, "`nPaina 'OK' sulkeaksesi tämän ruudun ja`nsiirtyäksesi eteenpäin")
MyGui.Add("Button",, "OK").OnEvent("Click", seuraavatTarrat)
MyGui.Add("Button",, "Päivitys").OnEvent("Click", update)
MyGui.Show()
Return

SendTabs(times)
{
	Loop times
	{
		Send "{Tab}"
		Sleep 100
	}
	return
}

update(*)
{
	Download "https://raw.githubusercontent.com/avaruusvelho/Nidetunnus-apuri/refs/heads/main/Nidetunnukset.ahk", "Nidetunnukset.ahk"
}

seuraavatTarrat(*)
{   
	Saved := MyGui.Submit()
	edellinenNidetunnus := Saved.Nidetunnus
	varaNidetunnus := edellinenNidetunnus ;Tämä erroreita varten
	
	;Seuraavaksi apufilun luku/teko ja säästetyn kokonaistyöajan alustus
	try ;Koitetaan lukea apufilua
	{
		HelpFileObj := FileOpen(A_Desktop "\apufilu.txt", "r")
		kokonaisAika := HelpFileObj.ReadLine()
		niteet := HelpFileObj.ReadLine()
		HelpFileObj.Close()
	}
	catch OSError ;Tämä ottaa kiinni jos syystä tai toisesta filua ei löydy
	{
		HelpFileObj := FileOpen(A_Desktop "\apufilu.txt", "rw") ;Tämä tekee uuden filun
		kokonaisAika := 0
		niteet := 0
		HelpFileObj.Close()
	}

	FileObj := FileOpen(A_Desktop "\Virhelogi.txt", "a")
	FileObj.WriteLine("---------------------------------------------UUSI SUORITUS-----------------------------------------------------")
	FileObj.WriteLine("Aloitus: " FormatTime(A_Now, ))
	aikaAlussa := A_Now

	; Odotetaan käyttäjältä a:n painoa
	KeyWait "a", "D"
	Sleep 500

	Loop Saved.Tarramaara
	{
		;Tyhjätään leikepöytä
		A_Clipboard := ""
		
		nidetunnuksenTallennus:
		
		; Tallennetaan seuraavaksi 8 viimeistä numeroa omiin muuttujiin
		vika := Integer(SubStr(edellinenNidetunnus, -1, 1))
		viimeisetSeitseman := Integer(SubStr(edellinenNidetunnus, -8, 7))
		tokavika := Integer(SubStr(edellinenNidetunnus, -2, 1))
		kolmasvika := Integer(SubStr(edellinenNidetunnus, -3, 1))
		neljasvika := Integer(SubStr(edellinenNidetunnus, -4, 1))
		viidesvika := Integer(SubStr(edellinenNidetunnus, -5, 1))
		kuudesvika := Integer(SubStr(edellinenNidetunnus, -6, 1))
		seitsemasvika := Integer(SubStr(edellinenNidetunnus, -7, 1))
		kahdeksasvika := Integer(SubStr(edellinenNidetunnus, -8, 1))
		loppuosa := String(viimeisetSeitseman vika)
		
		nidetunnuksenTarkistus:
		
		Send "^{a}"
		Sleep 100
		Send "^{a}"
		Sleep 400
		Send "^{c}"
		Sleep 100
		Send "^{c}"
		Sleep 400
		
		;Tähän väliin tarkistus, että ollaan varmasti oikeassa kohdassa
		if (InStr(A_Clipboard, "LKES" , 1, 1) = 0)
		{
			jatketaanko := MsgBox("Ohjelma törmäsi ongelmaan, Aurora luultavasti hidastelee. Haluatko jatkaa vai keskeyttää?`n`nJos haluat jatkaa, paina 'Uudelleen'. Muutoin paina 'Peruuta'", "Virheilmoitus", "RetryCancel")
			if (jatketaanko = "Retry")
			{
				Result := MsgBox("Tarkista, että " varaNidetunnus " on viimeisin nidetunnus, joka on tallennettu.`nTämän jälkeen siirry seuraavaan niteeseen, mene nidetunnuksen kohdalle ja paina 'a' jatkaaksesi.", "Virheilmoitus", "YesNo")
				if (Result = "Yes")
				{
					Sleep 100
					MsgBox "Siirry seuraavaan niteeseen, mene nidetunnuksen kohdalle ja paina 'a' jatkaaksesi."
					
					; Odotetaan käyttäjältä a:n painoa
					KeyWait "a", "D"
					Goto nidetunnuksenTarkistus
				}
				else
				{
					FileObj.WriteLine("Suoritus päättyi virheeseen. Viimeisin leikepöydälle jäänyt sisältö: " A_Clipboard " Viimeisin syötetty nidetunnus: " varaNidetunnus)
					aikaLopussa := A_Now
					FileObj.WriteLine("Lopetus: " FormatTime(A_Now, ))
					aikaKulunutSekuntit := DateDiff(aikaLopussa, aikaAlussa, "seconds")
					aikaKulunutMinuutit := aikaKulunutSekuntit / 60			
					kokonaisAika := kokonaisaika + aikaKulunutSekuntit
				
					;Kirjoitetaan apufilun päälle uusi kokonaisaika
					HelpFileObj := FileOpen(A_Desktop "\apufilu.txt", "w")
					HelpFileObj.WriteLine(kokonaisAika)
					HelpFileObj.WriteLine(niteet)
					HelpFileObj.Close()
					
					FileObj.WriteLine("Tämän suorituksen säästämä aika sekunteissa: " aikaKulunutSekuntit)
					FileObj.WriteLine("Tämän suorituksen säästämä aika minuuteissa: " aikaKulunutMinuutit)
					FileObj.WriteLine("Kertynyt säästetty kokonaistyöaika sekunteissa: " kokonaisAika)
					FileObj.WriteLine("Kertynyt säästetty kokonaistyöaika minuuteissa: " kokonaisAika / 60)
					FileObj.WriteLine("Nidetarrojen määrä kokonaisuudessaan tähän asti: " niteet)
					Sleep 100
					FileObj.Close()
					Sleep 100
					MsgBox "Valmista! Voit sulkea ikkunan.`n`n---------------Sitten vähän ihanaa statistiikkaa---------------`nTähän suoritukseen mennyt aika sekunteissa: " aikaKulunutSekuntit "`nTähän suoritukseen mennyt aika minuuteissa: " aikaKulunutMinuutit "`nKertynyt säästetty kokonaistyöaika minuuteissa: " kokonaisAika / 60 "`nNidetarrojen määrä kokonaisuudessaan tähän asti: " niteet
					ExitApp
				}
			}
			else
			{
				FileObj.WriteLine("Suoritus päättyi virheeseen. Viimeisin leikepöydälle jäänyt sisältö: " A_Clipboard " Viimeisin syötetty nidetunnus: " varaNidetunnus)
				aikaLopussa := A_Now
				FileObj.WriteLine("Lopetus: " FormatTime(A_Now, ))
				aikaKulunutSekuntit := DateDiff(aikaLopussa, aikaAlussa, "seconds")
				aikaKulunutMinuutit := aikaKulunutSekuntit / 60			
				kokonaisAika := kokonaisaika + aikaKulunutSekuntit
			
				;Kirjoitetaan apufilun päälle uusi kokonaisaika
				HelpFileObj := FileOpen(A_Desktop "\apufilu.txt", "w")
				HelpFileObj.WriteLine(kokonaisAika)
				HelpFileObj.WriteLine(niteet)
				HelpFileObj.Close()
				
				FileObj.WriteLine("Tämän suorituksen säästämä aika sekunteissa: " aikaKulunutSekuntit)
				FileObj.WriteLine("Tämän suorituksen säästämä aika minuuteissa: " aikaKulunutMinuutit)
				FileObj.WriteLine("Kertynyt säästetty kokonaistyöaika sekunteissa: " kokonaisAika)
				FileObj.WriteLine("Kertynyt säästetty kokonaistyöaika minuuteissa: " kokonaisAika / 60)
				FileObj.WriteLine("Nidetarrojen määrä kokonaisuudessaan tähän asti: " niteet)
				Sleep 100
				FileObj.Close()
				Sleep 100
				MsgBox "Valmista! Voit sulkea ikkunan.`n`n---------------Sitten vähän ihanaa statistiikkaa---------------`nTähän suoritukseen mennyt aika sekunteissa: " aikaKulunutSekuntit "`nTähän suoritukseen mennyt aika minuuteissa: " aikaKulunutMinuutit "`nKertynyt säästetty kokonaistyöaika minuuteissa: " kokonaisAika / 60 "`nNidetarrojen määrä kokonaisuudessaan tähän asti: " niteet
				ExitApp
			}
		}
		
		Sleep 500
		edellinenNidetunnus := StrUpper(edellinenNidetunnus)
		Send edellinenNidetunnus
		Sleep 500
		
		;Tässä välissä eritellään, ollaanko tulostettu tarrat vai ei ja toimitaan tilanteen mukaan
		if (Saved.eiTulostettu = 1)
		{
			;Tarroja ei ole vielä tulostettu, siirretään nide tarroitettavien siiloon
			SendTabs(20)
			Sleep 500
			Send "{Space}"
			;Välilyönti -> Siirretään siiloon
			Sleep 2500
			SendTabs(13)
		}
		else if (Saved.onTulostettu = 1)
		{
			;Tarrat on jo tulostettu, siirrytään suoraan tallentamaan
			SendTabs(29)
		}
		
		Sleep 500
		Send "{Enter}"
		;Enter -> Tallennetaan
		niteet := niteet + 1
		Sleep 5000
		
		if (A_Index = 1)
		{
			SendTabs(4)
			Sleep 500
			Send "{Enter}"
			;Enter -> Siirrytään seuraavaan niteeseen
			Sleep 2500
			
			;Tarkistetaan, jos niteitä on vain kaksi vai enemmän
			if (Saved.Tarramaara = 2)
			{
				if (Saved.eiTulostettu = 1)
				{
					;Tarroja ei ole tulostettu, siirrytään siis viisi Tabia eteenpäin
					SendTabs(5)
				}
				else if (Saved.onTulostettu = 1)
				{
					;Tarrat on jo tulostettu, siirrytään siis neljä Tabia eteenpäin
					SendTabs(4)
				}
				Sleep 500
			}
			else
			{
				if (Saved.eiTulostettu = 1)
				{
					;Tarroja ei ole tulostettu, siirrytään siis kuusi Tabia eteenpäin
					SendTabs(6)

				}
				else if (Saved.onTulostettu = 1)
				{
					;Tarrat on jo tulostettu, siirrytään siis viisi Tabia eteenpäin
					SendTabs(5)
				}
				Sleep 500
			}
		}
		else if (A_Index < Saved.Tarramaara - 1)
		{
			SendTabs(5)
			Sleep 500
			Send "{Enter}"
			;Enter -> Siirrytään seuraavaan niteeseen
			Sleep 2500
			
			if (Saved.eiTulostettu = 1)
			{
				;Tarroja ei ole tulostettu, siirrytään siis kuusi Tabia eteenpäin
				SendTabs(6)
			}
			else if (Saved.onTulostettu = 1)
			{
				;Tarrat on jo tulostettu, siirrytään siis viisi Tabia eteenpäin
				SendTabs(5)
			}
			
			Sleep 500
		}
		else if (A_Index = Saved.Tarramaara - 1)
		{
			SendTabs(5)
			Sleep 500
			Send "{Enter}"
			;Enter -> Siirrytään seuraavaan niteeseen
			Sleep 2500
			
			if (Saved.eiTulostettu = 1)
			{
				;Tarroja ei ole tulostettu, siirrytään siis viisi Tabia eteenpäin
				SendTabs(5)
			}
			else if (Saved.onTulostettu = 1)
			{
				;Tarrat on jo tulostettu, siirrytään siis neljä Tabia eteenpäin
				SendTabs(4)
			}
			
			Sleep 500
		}
		
		;Lasketaan seuraava nidetunnus
		viimeisetSeitseman++
		tokavika := Integer(SubStr(viimeisetSeitseman, 7, 1))
		kolmasvika := Integer(SubStr(viimeisetSeitseman, 6, 1))
		neljasvika := Integer(SubStr(viimeisetSeitseman, 5, 1))
		viidesvika := Integer(SubStr(viimeisetSeitseman, 4, 1))
		kuudesvika := Integer(SubStr(viimeisetSeitseman, 3, 1))
		seitsemasvika := Integer(SubStr(viimeisetSeitseman, 2, 1))
		kahdeksasvika := Integer(SubStr(viimeisetSeitseman, 1, 1))
		vika := Mod(((kahdeksasvika*2)+(seitsemasvika*1)+(kuudesvika*2)+(viidesvika*1)+(neljasvika*2)+(kolmasvika*1)+(tokavika*2)), 10)
		uusiloppuosa := String(viimeisetSeitseman vika)
		seuraavaNidetunnus := StrReplace(edellinenNidetunnus, loppuosa, uusiloppuosa)
		varaNidetunnus := edellinenNidetunnus
		edellinenNidetunnus := seuraavaNidetunnus
	}
		aikaLopussa := A_Now
		FileObj.WriteLine("Lopetus: " FormatTime(A_Now, ))
		aikaKulunutSekuntit := DateDiff(aikaLopussa, aikaAlussa, "seconds")
		aikaKulunutMinuutit := aikaKulunutSekuntit / 60			
		kokonaisAika := kokonaisaika + aikaKulunutSekuntit
		
		;Kirjoitetaan apufilun päälle uusi kokonaisaika
		HelpFileObj := FileOpen(A_Desktop "\apufilu.txt", "w")
		HelpFileObj.WriteLine(kokonaisAika)
		HelpFileObj.WriteLine(niteet)
		HelpFileObj.Close()
		
		FileObj.WriteLine("Tämän suorituksen säästämä aika sekunteissa: " aikaKulunutSekuntit)
		FileObj.WriteLine("Tämän suorituksen säästämä aika minuuteissa: " aikaKulunutMinuutit)
		FileObj.WriteLine("Kertynyt säästetty kokonaistyöaika sekunteissa: " kokonaisAika)
		FileObj.WriteLine("Kertynyt säästetty kokonaistyöaika minuuteissa: " kokonaisAika / 60)
		FileObj.WriteLine("Nidetarrojen määrä kokonaisuudessaan tähän asti: " niteet)
		Sleep 500
		FileObj.Close()
		MsgBox "Valmista! Voit sulkea ikkunan.`n`n---------------Sitten vähän ihanaa statistiikkaa---------------`nTähän suoritukseen mennyt aika sekunteissa: " aikaKulunutSekuntit "`nTähän suoritukseen mennyt aika minuuteissa: " aikaKulunutMinuutit "`nKertynyt säästetty kokonaistyöaika minuuteissa: " kokonaisAika / 60 "`nNidetarrojen määrä kokonaisuudessaan tähän asti: " niteet
		ExitApp
	}
