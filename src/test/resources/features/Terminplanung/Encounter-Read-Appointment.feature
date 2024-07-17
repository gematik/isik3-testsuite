@terminplanung
@optional
@Encounter-Read-Appointment
Feature: Lesen der Ressource Encounter mit Terminverknüpfung (@Encounter-Read-Appointment)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Appointment-Read muss zuvor erfolgreich ausgeführt worden sein.
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz sowie die zugewiesene einrichtungsinterne Aufnahmenummer muss in der Konfigurationsvariable 'encounter-read-appointment-id' hinterlegt sein.

      Testdatensatz (Name: Wert)Legen Sie den folgenden Kontakt mit einer Gesundheitseinrichtung in Ihrem System an:
      Aufnahmenummer: Valide Aufnahmenummer vergeben durch das zu testende System (Bitte ID in den Konfigurationsvariablen 'encounter-read-appointment-identifier-system' und 'encounter-read-appointment-identifier-value' hinterlegt sein)
      Kontaktebene: Abteilungskontakt
      Status: Durchgeführt
      Typ: Normalstationär
      Patient: Der Patient aus Testfall Appointment-Read
      Referenzierter Termin: Der Termin aus Testfall Appointment-Read
    """

  Scenario: Read eines Encounter anhand der ID
    Then Get FHIR resource at "http://fhirserver/Encounter/${data.encounter-read-appointment-id}" with content type "json"
    And resource has ID "${data.encounter-read-appointment-id}"
    And FHIR current response body is a valid isik3-terminplanung resource and conforms to profile "https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKTerminKontaktMitGesundheitseinrichtung"
    And TGR current response with attribute "$.body.status.content" matches "finished"
    And FHIR current response body evaluates the FHIRPath "identifier.where(system = '${data.encounter-read-appointment-identifier-system}' and value='${data.encounter-read-appointment-identifier-value}').exists()" with error message 'Der Kontakt enthält nicht die korrekte Aufnahmenummer'
    And FHIR current response body evaluates the FHIRPath "class.where(code = 'IMP' and system = 'http://terminology.hl7.org/CodeSystem/v3-ActCode').exists()" with error message 'Der Kontakt enthält nicht die korrekte Art'
    And FHIR current response body evaluates the FHIRPath "type.coding.where(code = 'abteilungskontakt' and system = 'http://fhir.de/CodeSystem/Kontaktebene').exists()" with error message 'Der Kontakt enthält nicht den korrekten Typ'
    And element "appointment" references resource with ID "Appointment/${data.appointment-read-id}" with error message "Der referenzierte Termin entspricht nicht dem Erwartungswert"
