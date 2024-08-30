@basis
@mandatory
@Encounter-Search
Feature: Testen von Suchparametern gegen encounter-read-in-progress (@Encounter-Search)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Encounter-Read-In-Progress, Account-Read müssen zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "search-type" for resource "Encounter"

  Scenario Outline: Validierung der Suchparameter-Definitionen im CapabilityStatement
    And CapabilityStatement contains definition of search parameter "<searchParamValue>" of type "<searchParamType>" for resource "Encounter"

    Examples:
      | searchParamValue | searchParamType |
      | _id              | token           |
      | identifier       | token           |
      | status           | token           |
      | class            | token           |
      | type             | token           |
      | subject          | reference       |
      | patient          | reference       |
      | account          | reference       |
      | date             | date            |
      | date-start       | date            |
      | end-date         | date            |

  Scenario: Suche nach dem Encounter anhand der ID
    Then Get FHIR resource at "http://fhirserver/Encounter/?_id=${data.encounter-read-in-progress-id}" with content type "xml"
    And response bundle contains resource with ID "${data.encounter-read-in-progress-id}" with error message "Der gesuchte Encounter ${data.encounter-read-in-progress-id} ist nicht im Responsebundle enthalten"
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "Encounter" is valid isik3-basismodul resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKKontaktGesundheitseinrichtung"

  Scenario: Suche des Encounters anhand des Status
    Then Get FHIR resource at "http://fhirserver/Encounter/?status=in-progress" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(status = 'in-progress')" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche des Encounters anhand der Klasse
    Then Get FHIR resource at "http://fhirserver/Encounter/?class=http://terminology.hl7.org/CodeSystem/v3-ActCode%7CIMP" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(class.where(code = 'IMP' and system = 'http://terminology.hl7.org/CodeSystem/v3-ActCode').exists())" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche des Encounters anhand des Typs
    Then Get FHIR resource at "http://fhirserver/Encounter/?type=http://fhir.de/CodeSystem/kontaktart-de%7Cnormalstationaer" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(type.coding.where(code = 'normalstationaer' and system = 'http://fhir.de/CodeSystem/kontaktart-de').exists())" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche des Encounters anhand der Patienten-Id (Suchparameter patient)
    Then Get FHIR resource at "http://fhirserver/Encounter/?patient=${data.patient-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And element "subject" in all bundle resources references resource with ID "${data.patient-read-id}"

  Scenario: Suche des Encounters anhand der Patienten-Id (Suchparameter subject)
    Then Get FHIR resource at "http://fhirserver/Encounter/?subject=Patient/${data.patient-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And element "subject" in all bundle resources references resource with ID "${data.patient-read-id}"

  Scenario: Suche des Encounters anhand der Account-Id
    Then Get FHIR resource at "http://fhirserver/Encounter/?account=${data.account-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And element "account" in all bundle resources references resource with ID "${data.account-read-id}"

  Scenario: Suche des Encounters anhand des Account-Identifiers
    Then Get FHIR resource at "http://fhirserver/Encounter/?account:identifier=${data.account-read-identifier-system}%7C${data.account-read-identifier-value}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And element "account" in all bundle resources references resource with ID "${data.account-read-id}"

  Scenario: Suche des Encounters anhand des Aufnahmedatums mit 'le' Modifikator
    Then Get FHIR resource at "http://fhirserver/Encounter/?date=le2050-01-01" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(period.start <= @2050-01-01T23:59:59+01:00 or period.start.empty())" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche des Encounters anhand des Aufnahmedatums mit 'gt' Modifikator
    Then Get FHIR resource at "http://fhirserver/Encounter/?date=gt1999-01-01" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(period.end >= @1999-01-01T00:00:00+01:00 or period.end.empty())" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Negativsuche des Encounters anhand des Datums
    Then Get FHIR resource at "http://fhirserver/Encounter/?date=2021-02-11" with content type "xml"
    And bundle does not contain resource "Encounter" with ID "${data.encounter-read-in-progress-id}" with error message "Der gesuchte Encounter ${data.encounter-read-in-progress-id} darf hier nicht zurückgegeben werden"


#  Search all encounters, where the stay period intersects with [2021-02-11, 2021-02-14]
#
#  Matching instances:
#
#  Encounter
#  start: 2021-02-12 (>left boundary but < right boundary)
#  end: 2021-02-13 (<right boundary)
#  Encounter
#  start: 2021-02-12 (<left boundary)
#  end: 2021-03-01 (>right boundary)
#  Encounter
#  start: 2021-02-11 (=left boundary)
#  end: 2021-02-11 (=right boundary)
#  Encounter
#  start: 2021-02-14 (=end boundary)
#  end: 2021-02-14 (=end boundary)
#  Encounter
#  start: 2021-01-01 (<left boundary)
#  end: 2021-02-12 (<right boundary but > left boundary)
#  Encounter
#  start: 2021-01-01 (<left boundary)
#  Encounter
#  start: 2021-02-11 (=left boundary)
#  Encounter
#  start: 2021-02-12 (>left boundary but < right boundary)
#  Encounter
#  start: 2021-02-14 (=right boundary)
#  Encounter
#  end: 2021-02-11 (=left boundary)
#  Encounter
#  end: 2021-02-13 (<right boundary but > left boundary)
#  Encounter
#  end: 2021-03-01 (=right boundary)
#  Encounter
#  end: 2021-03-01 (>right boundary)
#
#  Non-matching instances:
#
#  Encounter
#  start: 2021-03-01 (> right boundary)
#  Encounter
#  end: 2021-02-10 (< left boundary)
#  Encounter
#  start: 2021-03-01 (> right boundary)
#  end: 2021-04-01 (> right boundary)
#  Encounter
#  start: 2020-11-01 (< left boundary)
#  end: 2021-02-10 (< left boundary)
#
#  Expression for non-matching instances: start.exists and start > upper bound or end.exists and end < left bound.
#  Expression for matching instances: not (expression for non-matching instances)

  Scenario: Suche des Encounters anhand des Aufnahmedatums mit 'ge' und 'le' Modifikatoren
    Then Get FHIR resource at "http://fhirserver/Encounter/?date=ge2021-02-11&date=le2021-02-14" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.select((period.start.exists() and period.start >  @2021-02-14T23:59:59+01:00) or (period.end.exists() and period.end < @2021-02-11T00:00:00+01:00)).allFalse()" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche des Encounters anhand des Aufnahmedatums mit dem Suchparameter end-date
    Then Get FHIR resource at "http://fhirserver/Encounter/?end-date=le2050-01-01" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(period.start <= @2050-01-01T23:59:59+01:00 or period.start.empty())" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche des Encounters anhand des Aufnahmedatums mit dem Suchparameter date-start
    Then Get FHIR resource at "http://fhirserver/Encounter/?date-start=ge1999-01-01" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(period.end >= @1999-01-01T00:00:59+01:00 or period.end.empty())" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Negativsuche des Encounters anhand des Suchparameters date-start
    Then Get FHIR resource at "http://fhirserver/Encounter/?date-start=ge2021-02-14" with content type "xml"
    And bundle does not contain resource "Encounter" with ID "${data.encounter-read-in-progress-id}" with error message "Der gesuchte Encounter ${data.encounter-read-in-progress-id} darf hier nicht zurückgegeben werden"

  Scenario: Negativsuche des Encounters anhand des Suchparameters end-date
    Then Get FHIR resource at "http://fhirserver/Encounter/?end-date=le2021-02-11" with content type "xml"
    And bundle does not contain resource "Encounter" with ID "${data.encounter-read-in-progress-id}" with error message "Der gesuchte Encounter ${data.encounter-read-in-progress-id} darf hier nicht zurückgegeben werden"

  Scenario: Suche des Encounters anhand des Aufnahmedatums mit mit dem Suchparameter end-date
    Then Get FHIR resource at "http://fhirserver/Encounter/?date-start=ge2021-02-11&end-date=le2021-02-14" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.select((period.start.exists() and period.start > @2021-02-14T00:00:00+01:00) or (period.end.exists() and period.end < @2021-02-11T23:59:59+01:00)).allFalse()" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche des Encounters anhand der Aufnahmenummer
    Then Get FHIR resource at "http://fhirserver/Encounter/?identifier=${data.encounter-read-in-progress-identifier-system}%7C${data.encounter-read-in-progress-identifier-value}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(identifier.where(value = '${data.encounter-read-in-progress-identifier-value}' and system = '${data.encounter-read-in-progress-identifier-system}').exists())" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche des Encounters anhand der PatientIn
    Then Get FHIR resource at "http://fhirserver/Encounter/?patient=${data.patient-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And element "subject" in all bundle resources references resource with ID "${data.patient-read-id}"

  Scenario: Suche der PatientIn anhand der Verknüpfung mit dem Fall (Chaining)
    Then Get FHIR resource at "http://fhirserver/Encounter/?subject.family=Graf%20von%20und%20zu%20Mustermann" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.where(subject.reference.replaceMatches('/_history/.+','').matches('\\b${data.patient-read-id}$')).exists()" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche des Encounters anhand des identifier.system
    Then Get FHIR resource at "http://fhirserver/Encounter/?identifier=${data.encounter-read-in-progress-identifier-system}%7C" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(identifier.where(system = '${data.encounter-read-in-progress-identifier-system}').exists())" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'
