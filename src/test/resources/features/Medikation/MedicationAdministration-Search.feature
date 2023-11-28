@medikation
@mandatory
@MedicationAdministration-Search
Feature: Testen von Suchparametern gegen die MedicationAdministration Ressource (@MedicationAdministration-Search)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Die Testfälle MedicationAdministration-Read und MedicationAdministration-Read-Extended müssen zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "MedicationAdministration" and interaction.where(code = "search-type").exists()).exists()
    """

  Scenario Outline: Validierung des CapabilityStatements von <searchParamValue>
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "MedicationAdministration" and searchParam.where(name = "<searchParamValue>" and type = "<searchParamType>").exists()).exists()
    """

    Examples:
      | searchParamValue | searchParamType |
      | _id              | token           |
      | code             | token           |
      | context          | reference       |
      | effective-time   | date            |
      | medication       | reference       |
      | patient          | reference       |
      | performer        | reference       |
      | status           | token           |

  Scenario: Suche der Medikationsverabreichung anhand der ID
    Then Get FHIR resource at "http://fhirserver/MedicationAdministration/?_id=${data.medicationadministration-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.where(id.replaceMatches("/_history/.+","").matches("${data.medicationadministration-read-id}")).count() = 1' with error message 'Die gesuchte Medikationsverabreichung ${data.medicationadministration-read-id} ist nicht im Responsebundle enthalten'
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "MedicationAdministration" is valid ISIK3 and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikationsVerabreichung"

  Scenario: Suche der Medikationsverabreichung anhand des Codes
    Then Get FHIR resource at "http://fhirserver/MedicationAdministration/?code=http://fhir.de/CodeSystem/bfarm/atc%7CV03AB23" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all((medication.coding.where(code = 'V03AB23' and system = 'http://fhir.de/CodeSystem/bfarm/atc').exists()))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Medikationsverabreichung anhand des Kontexts
    Then Get FHIR resource at "http://fhirserver/MedicationAdministration/?context=Encounter/${data.encounter-read-in-progress-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(context.reference.replaceMatches('/_history/.+','').matches('Encounter/${data.encounter-read-in-progress-id}'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Medikationsverabreichung anhand der Fallnummer des assoziierten Kontakts
    Then Get FHIR resource at "http://fhirserver/MedicationAdministration/?context.identifier=${data.encounter-identifier}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(context.identifier.value = '${data.encounter-identifier}' or context.reference.replaceMatches('/_history/.+','').matches('Encounter/${data.encounter-read-in-progress-id}'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Medikationsverabreichung anhand des Zeitraums und des Zeitpunkts
    Then Get FHIR resource at "http://fhirserver/MedicationAdministration/?effective-time=2021-07-01" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(effective.toString().contains('2021-07-01') or effective.start.toString().contains('2021-07-01') or effective.end.toString().contains('2021-07-01'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Medikationsverabreichung anhand des referenzierten Medikaments
    Then Get FHIR resource at "http://fhirserver/MedicationAdministration/?medication=Medication/${data.medication-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(medication.reference.replaceMatches('/_history/.+','').matches('Medication/${data.medication-read-id}'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Medikationsverabreichung anhand des Codes
    Then Get FHIR resource at "http://fhirserver/MedicationAdministration/?medication.code=http://fhir.de/CodeSystem/bfarm/atc%7CV03AB23" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(medication.coding.where(code = 'V03AB23' and system = 'http://fhir.de/CodeSystem/bfarm/atc').exists() or medication.reference.replaceMatches('/_history/.+','').matches('Medication/${data.medication-read-id}'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Medikationsverabreichung anhand der Patientenreferenz
    Then Get FHIR resource at "http://fhirserver/MedicationAdministration/?patient=Patient/${data.patient-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(subject.identifier.value='${data.patient-identifier}' or subject.reference.replaceMatches('/_history/.+','').matches('Patient/${data.patient-read-id}'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Medikationsverabreichung anhand der Referenz zur verabreichenden Person
    Then Get FHIR resource at "http://fhirserver/MedicationAdministration/?performer=Practitioner/${data.practitioner-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(performer.actor.reference.replaceMatches('/_history/.+','').matches('Practitioner/${data.practitioner-read-id}'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Medikationsverabreichung anhand des Identifiers der verabreichenden Person
    Then Get FHIR resource at "http://fhirserver/MedicationAdministration/?performer.identifier=${data.performer-identifier}" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(performer.actor.identifier.value='${data.performer-identifier}' or performer.actor.reference.replaceMatches('/_history/.+','').matches('Practitioner/${data.practitioner-read-id}'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Medikationsverabreichung anhand des Status
    Then Get FHIR resource at "http://fhirserver/MedicationAdministration/?status=completed" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(status = 'completed')" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'
