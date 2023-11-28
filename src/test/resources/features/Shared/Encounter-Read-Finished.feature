@basis
@dokumentenaustausch
@medikation
@vitalparameter
@mandatory
@Encounter-Read-Finished
Feature: Lesen der Ressource Encounter (@Encounter-Read-Finished)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - Die Testfälle Patient-Read, Appointment-Read müssen zuvor erfolgreich ausgeführt worden sein.
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz sowie die zugewiesene einrichtungsinterne Aufnahmenummer muss in der shared.yaml eingegeben worden sein.

      Testdatensatz (Name: Wert)
      Legen Sie den folgenden Kontakt mit einer Gesundheitseinrichtung in Ihrem System an:
      Aufnahmenummer: Beliebig (Bitte ID im shared.yaml eingeben)
      Status: Abgeschlossen
      Typ: Normalstationär
      Patient: Der Patient aus Testfall Patient-Read
      Aufnahmeanlass: Einweisung durch einen Arzt
      Fachabteilung: Allgemeine Chirurgie
      Aufnahmegrund (Erste und zweite Stelle): Krankenhausbehandlung, vollstationär
      Zeitraum: 2021-02-12 bis 2021-02-13
      Abrechnungsfall: Der Abrechnungsfall aus Testfall Account-Read
      Abrechnungsfall (Identifier): Der Identifier des verlinkten Abrechnungsfalls (Bitte ID im shared.yaml eingeben)
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "Encounter" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read eines Encounter anhand der ID
    Then Get FHIR resource at "http://fhirserver/Encounter/${data.encounter-read-finished-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.encounter-read-finished-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/Encounter"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKKontaktGesundheitseinrichtung"
    And TGR current response with attribute "$..status.value" matches "finished"
    And FHIR current response body evaluates the FHIRPath "identifier.where(system = '${data.encounter-read-finished-identifier-system}' and value='${data.encounter-read-finished-identifier-value}').exists()" with error message 'Der Kontakt enthält nicht die korrekte Aufnahmenummer'
    And FHIR current response body evaluates the FHIRPath "class.where(code = 'IMP' and system = 'http://terminology.hl7.org/CodeSystem/v3-ActCode').exists()" with error message 'Der Kontakt enthält nicht die korrekte Art'
    And FHIR current response body evaluates the FHIRPath "type.coding.where(code = 'normalstationaer' and system = 'http://fhir.de/CodeSystem/kontaktart-de').exists()" with error message 'Der Kontakt enthält nicht den korrekten Typ'
    And FHIR current response body evaluates the FHIRPath "serviceType.coding.where(code = '1500' and system = 'http://fhir.de/CodeSystem/dkgev/Fachabteilungsschluessel').exists()" with error message 'Der Kontakt enthält nicht den korrekten Fachabteilungsschlüssel'
    And FHIR current response body evaluates the FHIRPath "subject.reference.replaceMatches('/_history/.+','').matches('${data.patient-read-id}')" with error message 'Referenzierter Patient entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "period.start.toString().contains('2021-02-12')" with error message 'Der Kontakt enthält kein valides Startdatum'
    And FHIR current response body evaluates the FHIRPath "period.end.toString().contains('2021-02-13')" with error message 'Der Kontakt enthält kein valides Enddatum'
    And FHIR current response body evaluates the FHIRPath "hospitalization.admitSource.coding.where(code = 'E' and system = 'http://fhir.de/CodeSystem/dgkev/Aufnahmeanlass').exists()" with error message 'Der Kontakt enthält nicht den korrekten Aufnahmeanlass'
    And FHIR current response body evaluates the FHIRPath "extension.where(url = 'http://fhir.de/StructureDefinition/Aufnahmegrund' and extension.where(url = 'ErsteUndZweiteStelle' and value.code = '01' and value.system = 'http://fhir.de/CodeSystem/dkgev/AufnahmegrundErsteUndZweiteStelle').exists()).exists()" with error message 'Der Kontakt enthält nicht den korrekten Aufnahmegrund'
    And FHIR current response body evaluates the FHIRPath "account.reference.replaceMatches('/_history/.+','').matches('Account/${data.account-read-id}')" with error message 'Der verlinkte Abrechnungsfall entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "account.identifier.value = '${data.account-read-identifier-value}'" with error message 'Der Identifier des verlinkten Abrechnungsfalls entspricht nicht dem Erwartungswert'
