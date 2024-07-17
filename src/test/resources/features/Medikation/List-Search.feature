@medikation
@mandatory
@List-Search
Feature: Testen von Suchparametern gegen die Medikationsliste aus List-read (@List-Search)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall List-Read muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "List" and interaction.where(code = "search-type").exists()).exists()
    """

  Scenario Outline: Validierung des CapabilityStatements von <searchParamValue>
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "List" and searchParam.where(name = "<searchParamValue>" and type = "<searchParamType>").exists()).exists()
    """

    Examples:
      | searchParamValue | searchParamType |
      | _id              | token           |
      | code             | token           |
      | date             | date            |
      | encounter        | reference       |
      | item             | reference       |
      | patient          | reference       |
      | status           | token           |

  Scenario: Suche der Liste anhand der ID
    Then Get FHIR resource at "http://fhirserver/List/?_id=${data.list-read-id}" with content type "xml"
    And response bundle contains resource with ID "${data.list-read-id}" with error message "Die gesuchte Liste ${data.list-read-id} ist nicht im Responsebundle enthalten"
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "List" is valid isik3-medikation resource and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikationsListe"

  Scenario: Suche der Liste anhand des Codes
    Then Get FHIR resource at "http://fhirserver/List/?code=http://terminology.hl7.org/CodeSystem/list-example-use-codes%7Cmedications" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(code.coding.where(code = 'medications' and system = 'http://terminology.hl7.org/CodeSystem/list-example-use-codes').exists())" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche der Liste anhand des Datums
    Then Get FHIR resource at "http://fhirserver/List/?date=2021-07-04" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(date.toString().contains('2021-07-04'))" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche der Liste anhand der Referenz zum Fall
    Then Get FHIR resource at "http://fhirserver/List/?encounter=Encounter/${data.medication-encounter-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And element "encounter" in all bundle resources references resource with ID "Encounter/${data.medication-encounter-id}"

  Scenario: Suche der Liste anhand des Fall-Identifiers
    Then Get FHIR resource at "http://fhirserver/List/?encounter.identifier=${data.medication-encounter-identifier}" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.where(encounter.reference.replaceMatches('/_history/.+','').matches('Encounter/${data.medication-encounter-id}$')).exists()" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche der Liste anhand der Referenz zur PatientIn
    Then Get FHIR resource at "http://fhirserver/List/?patient=Patient/${data.medication-patient-id}" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And element "subject" in all bundle resources references resource with ID "Patient/${data.medication-patient-id}"

  Scenario: Suche der Liste anhand der Patientennummer
    Then Get FHIR resource at "http://fhirserver/List/?patient.identifier=${data.medication-patient-identifier}" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.where(subject.reference.replaceMatches('/_history/.+','').matches('Patient/${data.medication-patient-id}$')).exists()" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche der Liste anhand des Status
    Then Get FHIR resource at "http://fhirserver/List/?status=current" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(status = 'current')" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'
