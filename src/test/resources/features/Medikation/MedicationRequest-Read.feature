@medikation
@mandatory
@MedicationRequest-Read
Feature: Lesen der Ressource MedicationRequest (@MedicationRequest-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Medication-Read muss zuvor erfolgreich ausgeführt worden sein
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressourcen zu diesem Testdatensatz muss in der Konfigurationsvariable 'medicationrequest-read-id' hinterlegt sein.

      Legen Sie folgende Medikationsverordnung in Ihrem System an:
      Status: abgeschlossen
      Ziel der Verordnungsinformation: Order
      Referenziertes Medikament: Das Medikament aus Testfall Medication-Read
      Patient: Beliebig (die verknüpfte Patient-Ressource muss konform zu ISiKPatient sein, bitte die ID in der Konfigurationsvariable 'medication-patient-id' hinterlegen)
      Fallbezug: Beliebig (die verknüpfte Encounter-Ressource muss konform zu ISIKKontaktGesundheitseinrichtung sein, bitte die ID in der Konfigurationsvariable 'medication-encounter-id' hinterlegen)
      Assoziierter Kontakt-Identifier: Identifier des verlinkten Kontaktes
      Erstellungsdatum: 2021-07-01
      Verordnende Person: Beliebig (die verknüpfte Practitioner-Ressource muss konform zu ISiKPersonImGesundheitsberuf sein, bitte die ID in der Konfigurationsvariable 'medication-practitioner-id' hinterlegen)
      Notiz: Testnotiz
      Dosis (Text): Beliebig (nicht leer)
      Dosis: 1 Brausetablette
      Dosis (Körperstelle SNOMED CT kodiert): Oral
      Dosis (Verabreichungsrate): 1
      Dosis (Route SNOMED CT kodiert): Oral
      Angeforderte Abgabemenge: 20 Brausetabletten
      Ersatz zulässig: Ja
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "MedicationRequest"

  Scenario: Read eines Medikaments anhand der ID
    Then Get FHIR resource at "http://fhirserver/MedicationRequest/${data.medicationrequest-read-id}" with content type "xml"
    And resource has ID "${data.medicationrequest-read-id}"
    And FHIR current response body is a valid isik3-medikation resource and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikationsVerordnung"
    And TGR current response with attribute "$..status.value" matches "completed"
    And TGR current response with attribute "$..intent.value" matches "order"
    And TGR current response with attribute "$..note.text.value" matches "Testnotiz"
    And element "medication" references resource with ID "Medication/${data.medication-read-id}" with error message "Das referenzierte Medikament entspricht nicht dem Erwartungswert"
    And element "subject" references resource with ID "Patient/${data.medication-patient-id}" with error message "Der referenzierte Patient entspricht nicht dem Erwartungswert"
    And element "encounter" references resource with ID "Encounter/${data.medication-encounter-id}" with error message "Referenzierter Fall entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "encounter.identifier.value = '${data.medication-encounter-identifier}'" with error message 'Der assoziierte Kontakt Identifier entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "authoredOn.toString().contains('2021-07-01')" with error message 'Das Erstellungsdatum der Verordnung entspricht nicht dem Erwartungswert'
    And element "requester" references resource with ID "Practitioner/${data.medication-practitioner-id}" with error message "Die verordnende Person entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "dosageInstruction.where(text.empty().not() and site.coding.where(code = '738956005' and system = 'http://snomed.info/sct' and display = 'Oral').exists() and doseAndRate.where(dose.where(code = '1' and system = 'http://unitsofmeasure.org' and unit = 'Brausetablette' and value ~ 1).exists()).exists()).exists()" with error message 'Die Dosis entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dispenseRequest.quantity.where(value ~ 20 and unit = 'Brausetablette' and system = 'http://unitsofmeasure.org' and code = '1').exists()" with error message 'Die angeforderte Abgabemenge entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "substitution.allowed.value = true"

    And referenced Patient resource with id "${data.medication-patient-id}" conforms to ISiKPatient profile
    And referenced Encounter resource with id "${data.medication-encounter-id}" conforms to ISiKKontaktGesundheitseinrichtung profile
    And referenced Practitioner resource with id "${data.medication-practitioner-id}" conforms to ISiKPersonImGesundheitsberuf profile