@medikation
@mandatory
@List-Read
Feature: Lesen der Ressource List (@List-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall MedicationStatement-Read muss zuvor erfolgreich ausgeführt worden sein.
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der Konfigurationsvariable 'list-read-id' hinterlegt sein.

      Erfassen Sie folgende Medikamentenliste (Name: Wert):
      Status: Aktuell
      Listenmodus: Kontinuierlich fortgeschriebene Liste
      Patient: Beliebig (die verknüpfte Patient-Ressource muss konform zu ISiKPatient sein, bitte die ID in der Konfigurationsvariable 'medication-patient-id' hinterlegen)
      Kontakt: Beliebig (die verknüpfte Encounter-Ressource muss konform zu ISIKKontaktGesundheitseinrichtung sein, bitte die ID in der Konfigurationsvariable 'medication-encounter-id' hinterlegen)
      Datum: 2021-07-04
      Listeneintrag 1 (Datum): 2021-07-04
      Listeneintrag 1 (Medikationsinformation): Medikationsinformation aus Testfall MedicationStatement-Read
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "List"

  Scenario: Read eines Account anhand der ID
    Then Get FHIR resource at "http://fhirserver/List/${data.list-read-id}" with content type "xml"
    And resource has ID "${data.list-read-id}"
    And FHIR current response body is a valid isik3-medikation resource and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikationsListe"
    And TGR current response with attribute "$..status.value" matches "current"
    And TGR current response with attribute "$..mode.value" matches "working"
    And FHIR current response body evaluates the FHIRPath "code.coding.where(code = 'medications' and system = 'http://terminology.hl7.org/CodeSystem/list-example-use-codes').exists()" with error message 'Der Code entspricht nicht dem Erwartungswert'
    And element "subject" references resource with ID "Patient/${data.medication-patient-id}" with error message "Der referenzierte Patient entspricht nicht dem Erwartungswert"
    And element "encounter" references resource with ID "Encounter/${data.medication-encounter-id}" with error message "Der referenzierte Fall entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "date.toString().contains('2021-07-04')" with error message 'Das Datum entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "entry.where(item.reference.replaceMatches('/_history/.+','').matches('MedicationStatement/${data.medicationstatement-read-id}$') and date.toString().contains('2021-07-04')).exists()" with error message 'Der Listeneintrag entspricht nicht dem Erwartungswert'

    And referenced Patient resource with id "${data.medication-patient-id}" conforms to ISiKPatient profile
    And referenced Encounter resource with id "${data.medication-encounter-id}" conforms to ISiKKontaktGesundheitseinrichtung profile