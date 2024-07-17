@basis
@mandatory
@Encounter-Read-Finished
Feature: Lesen der Ressource Encounter (@Encounter-Read-Finished)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      -Der Testfall Account-Read muss zuvor erfolgreich ausgeführt worden sein.
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz sowie die zugewiesene einrichtungsinterne Aufnahmenummer muss in der Konfigurationsvariable 'encounter-read-finished-id' hinterlegt sein.

      Testdatensatz (Name: Wert)Legen Sie den folgenden Kontakt in Ihrem System an:
      Aufnahmenummer: Beliebig (Bitte in der Konfigurationsvariable 'encounter-read-finished-identifier-value' hinterlegen)
      Status: Abgeschlossen
      Typ: Normalstationär
      Patient: Der Patient aus Testfall Account-Read
      Aufnahmeanlass: Einweisung durch einen Arzt
      Fachabteilung: Allgemeine Chirurgie
      Aufnahmegrund (Erste und zweite Stelle): Krankenhausbehandlung, vollstationär
      Zeitraum: 2021-02-12 bis 2021-02-13
      Abrechnungsfall: Der Abrechnungsfall aus Testfall Account-Read
      Abrechnungsfall (Identifier): Der Identifier des verlinkten Abrechnungsfalls
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "Encounter"

  Scenario: Read eines Encounter anhand der ID
    Then Get FHIR resource at "http://fhirserver/Encounter/${data.encounter-read-finished-id}" with content type "xml"
    And resource has ID "${data.encounter-read-finished-id}"
    And FHIR current response body is a valid isik3-basismodul resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKKontaktGesundheitseinrichtung"
    And TGR current response with attribute "$..status.value" matches "finished"
    And FHIR current response body evaluates the FHIRPath "identifier.where(system = '${data.encounter-read-finished-identifier-system}' and value='${data.encounter-read-finished-identifier-value}').exists()" with error message 'Der Kontakt enthält nicht die korrekte Aufnahmenummer'
    And FHIR current response body evaluates the FHIRPath "class.where(code = 'IMP' and system = 'http://terminology.hl7.org/CodeSystem/v3-ActCode').exists()" with error message 'Der Kontakt enthält nicht die korrekte Art'
    And FHIR current response body evaluates the FHIRPath "type.coding.where(code = 'normalstationaer' and system = 'http://fhir.de/CodeSystem/kontaktart-de').exists()" with error message 'Der Kontakt enthält nicht den korrekten Typ'
    And FHIR current response body evaluates the FHIRPath "serviceType.coding.where(code = '1500' and system = 'http://fhir.de/CodeSystem/dkgev/Fachabteilungsschluessel').exists()" with error message 'Der Kontakt enthält nicht den korrekten Fachabteilungsschlüssel'
    And element "subject" references resource with ID "${data.account-read-patient-id}" with error message "Referenzierter Patient entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "period.start.toString().contains('2021-02-12')" with error message 'Der Kontakt enthält kein valides Startdatum'
    And FHIR current response body evaluates the FHIRPath "period.end.toString().contains('2021-02-13')" with error message 'Der Kontakt enthält kein valides Enddatum'
    And FHIR current response body evaluates the FHIRPath "hospitalization.admitSource.coding.where(code = 'E' and system = 'http://fhir.de/CodeSystem/dgkev/Aufnahmeanlass').exists()" with error message 'Der Kontakt enthält nicht den korrekten Aufnahmeanlass'
    And FHIR current response body evaluates the FHIRPath "extension.where(url = 'http://fhir.de/StructureDefinition/Aufnahmegrund' and extension.where(url = 'ErsteUndZweiteStelle' and value.code = '01' and value.system = 'http://fhir.de/CodeSystem/dkgev/AufnahmegrundErsteUndZweiteStelle').exists()).exists()" with error message 'Der Kontakt enthält nicht den korrekten Aufnahmegrund'
    And element "account" references resource with ID "Account/${data.account-read-id}" with error message "Der verlinkte Abrechnungsfall entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "account.identifier.value = '${data.account-read-identifier-value}'" with error message 'Der Identifier des verlinkten Abrechnungsfalls entspricht nicht dem Erwartungswert'
