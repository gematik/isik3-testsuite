@basis
@dokumentenaustausch
@medikation
@vitalparameter
@mandatory
@Encounter-Read-Planned
Feature: Lesen der Ressource Encounter (@Encounter-Read-Planned)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Patient-Read muss zuvor erfolgreich ausgeführt worden sein.
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz sowie die zugewiesene einrichtungsinterne Aufnahmenummer muss in der shared.yaml eingegeben worden sein.

      Testdatensatz (Name: Wert)Legen Sie den folgenden Kontakt in Ihrem System an:
      Aufnahmenummer: Valide Aufnahmenummer vergeben durch das zu testende System
      Status: geplant
      Typ: Normalstationär
      Patient: Der Patient aus Testfall Patient-Read
      Aufnahmeanlass: Einweisung durch einen Arzt
      Fachabteilung: Allgemeine Chirurgie
      Location (Display): Chirurgie
      Leistungsanbieter (Display): Krankenhaus
      Leistungsanbieter ID (Wert): Beliebig (Bitte im shared.yaml eingeben)
      Geplanter Beginn: 2021-02-12
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "Encounter" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read eines Encounter anhand der ID
    Then Get FHIR resource at "http://fhirserver/Encounter/${data.encounter-read-planned-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.encounter-read-planned-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/Encounter"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKKontaktGesundheitseinrichtung"
    And TGR current response with attribute "$..status.value" matches "planned"
    And FHIR current response body evaluates the FHIRPath "identifier.where(system = '${data.encounter-read-planned-identifier-system}' and value='${data.encounter-read-planned-identifier-value}').exists()" with error message 'Der Kontakt enthält nicht die korrekte Aufnahmenummer'
    And FHIR current response body evaluates the FHIRPath "class.where(code = 'IMP' and system = 'http://terminology.hl7.org/CodeSystem/v3-ActCode').exists()" with error message 'Der Kontakt enthält nicht die korrekte Art'
    And FHIR current response body evaluates the FHIRPath "type.coding.where(code = 'normalstationaer' and system = 'http://fhir.de/CodeSystem/kontaktart-de').exists()" with error message 'Der Kontakt enthält nicht den korrekten Typ'
    And FHIR current response body evaluates the FHIRPath "serviceType.coding.where(code = '1500' and system = 'http://fhir.de/CodeSystem/dkgev/Fachabteilungsschluessel').exists()" with error message 'Der Kontakt enthält nicht den korrekten Fachabteilungsschlüssel'
    And FHIR current response body evaluates the FHIRPath "subject.reference.replaceMatches('/_history/.+','').matches('${data.patient-read-id}')" with error message 'Referenzierter Patient entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "hospitalization.admitSource.coding.where(code = 'E' and system = 'http://fhir.de/CodeSystem/dgkev/Aufnahmeanlass').exists()" with error message 'Der Kontakt enthält nicht den korrekten Aufnahmeanlass'
    And FHIR current response body evaluates the FHIRPath "location.location.display = 'Chirurgie'" with error message 'Der Display Location Wert entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "serviceProvider.display = 'Krankenhaus'" with error message 'Der Display Wert des Leistungsanbieters entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "serviceProvider.identifier.value = '${data.encounter-read-planned-serviceprovider-identifier-value}'" with error message 'Der Identifier Wert des Leistungsanbieters entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "period.exists().not()" with error message 'Ein geplanter Kontakt sollte keinen Zeitraum enthalten'
    And FHIR current response body evaluates the FHIRPath "extension.where(url = 'http://hl7.org/fhir/5.0/StructureDefinition/extension-Encounter.plannedStartDate' and value.toString().contains('2021-02-12')).exists()" with error message 'Das geplante Startdatum ist nicht vorhanden'
