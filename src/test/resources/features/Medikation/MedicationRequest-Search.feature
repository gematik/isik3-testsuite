@medikation
@mandatory
@MedicationRequest-Search
Feature: Testen von Suchparametern gegen die MedicationRequest Ressource (@MedicationRequest-Search)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Die Testfälle MedicationRequest-Read und MedicationRequest-Read-Extended müssen zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "MedicationRequest" and interaction.where(code = "search-type").exists()).exists()
    """

  Scenario Outline: Validierung des CapabilityStatements von <searchParamValue>
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "MedicationRequest" and searchParam.where(name = "<searchParamValue>" and type = "<searchParamType>").exists()).exists()
    """

    Examples:
      | searchParamValue | searchParamType |
      | _id              | token           |
      | authoredon       | date            |
      | code             | token           |
      | date             | date            |
      | encounter        | reference       |
      | intent           | token           |
      | medication       | reference       |
      | patient          | reference       |
      | requester        | reference       |
      | status           | token           |

  Scenario: Suche der Medikationsverordnung anhand der ID
    Then Get FHIR resource at "http://fhirserver/MedicationRequest/?_id=${data.medicationrequest-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPaths:
    """
      entry.resource.where(id.replaceMatches('/_history/.+','').matches('${data.medicationrequest-read-id}')).count()=1
    """
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "MedicationRequest" is valid ISIK3 and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikationsVerordnung"

  Scenario: Suche der Medikationsverordnung anhand des Zeitraums und des Zeitpunkts
    Then Get FHIR resource at "http://fhirserver/MedicationRequest/?authoredon=2021-07-01" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(authoredOn.toString().contains('2021-07-01'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Medikationsverordnung anhand des Codes
    Then Get FHIR resource at "http://fhirserver/MedicationRequest/?code=V03AB23" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all((medication.coding.where(code = 'V03AB23' and system = 'http://fhir.de/CodeSystem/bfarm/atc').exists()))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Medikationsverordnung anhand des Datums
    Then Get FHIR resource at "http://fhirserver/MedicationRequest/?date=2021-07-01" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(dosageInstruction.timing.event.toString().contains('2021-07-01'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Medikationsverordnung anhand des Kontakts
    Then Get FHIR resource at "http://fhirserver/MedicationRequest/?encounter=Encounter/${data.encounter-read-in-progress-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(encounter.reference.replaceMatches('/_history/.+','').matches('Encounter/${data.encounter-read-in-progress-id}'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Medikationsverordnung anhand der Fallnummer des assoziierten Kontakts
    Then Get FHIR resource at "http://fhirserver/MedicationRequest/?encounter.identifier=${data.encounter-identifier}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(encounter.identifier.value = '${data.encounter-identifier}')" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Medikationsverordnung anhand des Intents
    Then Get FHIR resource at "http://fhirserver/MedicationRequest/?intent=order" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(intent = 'order')" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Medikationsverordnung anhand des referenzierten Medikaments
    Then Get FHIR resource at "http://fhirserver/MedicationRequest/?medication=Medication/${data.medication-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(medication.reference.replaceMatches('/_history/.+','').matches('Medication/${data.medication-read-id}'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Medikationsverordnung anhand des Codes
    Then Get FHIR resource at "http://fhirserver/MedicationRequest/?code=http://fhir.de/CodeSystem/bfarm/atc%7CV03AB23" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(medication.coding.where(code = 'V03AB23' and system = 'http://fhir.de/CodeSystem/bfarm/atc').exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Medikationsverordnung anhand der Patientenreferenz
    Then Get FHIR resource at "http://fhirserver/MedicationRequest/?patient=Patient/${data.patient-read-id}" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(subject.reference.replaceMatches('/_history/.+','').matches('Patient/${data.patient-read-id}'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Medikationsverordnung anhand der Patientennummer
    Then Get FHIR resource at "http://fhirserver/MedicationRequest/?patient.identifier=${data.patient-identifier}" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(subject.identifier.value='${data.patient-identifier}' or subject.reference.replaceMatches('/_history/.+','').matches('Patient/${data.patient-read-id}'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Medikationsverordnung anhand der Referenz zur verordnenden Person
    Then Get FHIR resource at "http://fhirserver/MedicationRequest/?requester=Practitioner/${data.practitioner-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(requester.reference.replaceMatches('/_history/.+','').matches('Practitioner/${data.practitioner-read-id}'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Medikationsverordnung anhand des Identifiers der verordnenden Person
    Then Get FHIR resource at "http://fhirserver/MedicationRequest/?requester.identifier=${data.requester-identifier}" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(requester.identifier.value='${data.requester-identifier}' or requester.reference.replaceMatches('/_history/.+','').matches('Practitioner/${data.practitioner-read-id}'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Medikationsverordnung anhand des Status
    Then Get FHIR resource at "http://fhirserver/MedicationRequest/?status=completed" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(status = 'completed')" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'
    