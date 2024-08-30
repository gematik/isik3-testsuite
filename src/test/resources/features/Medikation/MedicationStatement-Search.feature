@medikation
@mandatory
@MedicationStatement-Search
Feature: Testen von Suchparametern gegen die MedicationStatement Ressource (@MedicationStatement-Search)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Die Testfälle MedicationStatement-Read und MedicationStatement-Read-Extended müssen zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "xml"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "MedicationStatement" and interaction.where(code = "search-type").exists()).exists()
    """

  Scenario Outline: Validierung der Suchparameter-Definitionen im CapabilityStatement
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "MedicationStatement" and searchParam.where(name = "<searchParamValue>" and type = "<searchParamType>").exists()).exists()
    """

    Examples:
      | searchParamValue | searchParamType |
      | _id              | token           |
      | code             | token           |
      | context          | reference       |
      | effective        | date            |
      | medication       | reference       |
      | patient          | reference       |
      | status           | token           |

  Scenario: Suche der Medikationsinformation anhand der ID
    Then Get FHIR resource at "http://fhirserver/MedicationStatement/?_id=${data.medicationstatement-read-id}" with content type "xml"
    And response bundle contains resource with ID "${data.medicationstatement-read-id}" with error message "Die gesuchte Medikationsinformation ${data.medicationstatement-read-id} ist nicht im Responsebundle enthalten"
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "MedicationStatement" is valid isik3-medikation resource and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikationsInformation"

  Scenario: Suche der Medikationsinformation anhand des Codes
    Then Get FHIR resource at "http://fhirserver/MedicationStatement/?code=http://fhir.de/CodeSystem/bfarm/atc%7CV03AB23" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    # The below assertion checks only entries with existing medication as CodableConcept and ignores others, which can be medicationReferences (cf. ANFISK-314)
    And FHIR current response body evaluates the FHIRPath "entry.resource.where(medication.coding.empty().not()).medication.coding.where(code = 'V03AB23' and system = 'http://fhir.de/CodeSystem/bfarm/atc').exists()" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche der Medikationsinformation anhand des Kontexts
    Then Get FHIR resource at "http://fhirserver/MedicationStatement/?context=Encounter/${data.medication-encounter-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And element "context" in all bundle resources references resource with ID "Encounter/${data.medication-encounter-id}"

  Scenario: Suche der Medikationsinformation anhand der Fallnummer des assoziierten Kontexts
    Then Get FHIR resource at "http://fhirserver/MedicationStatement/?context.identifier=${data.medication-encounter-identifier}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And element "context" in all bundle resources references resource with ID "Encounter/${data.medication-encounter-id}"

  Scenario: Suche der Medikationsinformation anhand des Zeitraums und des Zeitpunkts
    Then Get FHIR resource at "http://fhirserver/MedicationStatement/?effective=2022-07-01" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(effective.toString().contains('2022-07-01') or effective.start.toString().contains('2022-07-01') or effective.end.toString().contains('2022-07-01'))" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche der Medikationsinformation anhand des referenzierten Medikaments
    Then Get FHIR resource at "http://fhirserver/MedicationStatement/?medication=Medication/${data.medication-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And element "medication" in all bundle resources references resource with ID "Medication/${data.medication-read-id}"

  Scenario: Suche der Medikationsinformation anhand des Medikationscodes
    Then Get FHIR resource at "http://fhirserver/MedicationStatement/?medication.code=V03AB23" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And response bundle contains resource with ID "${data.medicationstatement-read-id}" with error message "Die Medikationsinformation mit ID ${data.medicationstatement-read-id} ist nicht im Responsebundle enthalten"

  Scenario: Suche der Medikationsinformation anhand der Patientenreferenz
    Then Get FHIR resource at "http://fhirserver/MedicationStatement/?patient=Patient/${data.medication-patient-id}" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And element "subject" in all bundle resources references resource with ID "Patient/${data.medication-patient-id}"

  Scenario: Suche der Medikationsinformation anhand der Patientennummer
    Then Get FHIR resource at "http://fhirserver/MedicationStatement/?patient.identifier=${data.medication-patient-identifier}" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And element "subject" in all bundle resources references resource with ID "Patient/${data.medication-patient-id}$"

  Scenario: Suche der Medikationsinformation anhand des Status
    Then Get FHIR resource at "http://fhirserver/MedicationStatement/?status=active" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(status = 'active')" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'
