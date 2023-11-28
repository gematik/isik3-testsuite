@basis
@dokumentenaustausch
@medikation
@vitalparameter
@mandatory
@Encounter-Search
Feature: Testen von Suchparametern gegen encounter-read-in-progress (@Encounter-Search)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Encounter-Read-In-Progress muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Encounter" and interaction.where(code = "search-type").exists()).exists()
    """

  Scenario Outline: Validierung des CapabilityStatements von <searchParamValue>
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Encounter" and searchParam.where(name = "<searchParamValue>" and type = "<searchParamType>").exists()).exists()
    """

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
    And FHIR current response body evaluates the FHIRPath 'entry.resource.where(id.replaceMatches("/_history/.+","").matches("${data.encounter-read-in-progress-id}")).count() = 1' with error message 'Der gesuchte Encounter ${data.encounter-read-in-progress-id} ist nicht im Responsebundle enthalten'
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "Encounter" is valid ISIK3 and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKKontaktGesundheitseinrichtung"

  Scenario: Suche des Encounters anhand des Status
    Then Get FHIR resource at "http://fhirserver/Encounter/?status=in-progress" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(status = 'in-progress')" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche des Encounters anhand der Klasse
    Then Get FHIR resource at "http://fhirserver/Encounter/?class=http://terminology.hl7.org/CodeSystem/v3-ActCode%7CIMP" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(class.where(code = 'IMP' and system = 'http://terminology.hl7.org/CodeSystem/v3-ActCode').exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche des Encounters anhand des Typs
    Then Get FHIR resource at "http://fhirserver/Encounter/?type=http://fhir.de/CodeSystem/kontaktart-de%7Cnormalstationaer" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(type.coding.where(code = 'normalstationaer' and system = 'http://fhir.de/CodeSystem/kontaktart-de').exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche des Encounters anhand der Patienten-Id
    Then Get FHIR resource at "http://fhirserver/Encounter/?patient=${data.patient-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(subject.reference.replaceMatches('/_history/.+','').matches('${data.patient-read-id}'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche des Encounters anhand der Patienten-Id
    Then Get FHIR resource at "http://fhirserver/Encounter/?subject=Patient/${data.patient-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(subject.reference.replaceMatches('/_history/.+','').matches('${data.patient-read-id}'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche des Encounters anhand des Aufnahmedatums mit 'le' Modifikator
    Then Get FHIR resource at "http://fhirserver/Encounter/?date=le2050-01-01" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(period.start <= @2050-01-01 or period.start.empty())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche des Encounters anhand des Aufnahmedatums mit 'gt' Modifikator
    Then Get FHIR resource at "http://fhirserver/Encounter/?date=gt1999-01-01" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(period.end >= @1999-01-01 or period.end.empty())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Negativsuche des Encounters anhand des Datums
    Then Get FHIR resource at "http://fhirserver/Encounter/?date=2021-02-11" with content type "xml"
    And FHIR current response body evaluates the FHIRPath "entry.resource.where(id.replaceMatches('/_history/.+','').matches('${data.encounter-read-in-progress-id}')).count() = 0" with error message 'Der gesuchte Encounter ${data.encounter-read-in-progress-id} darf hier nicht zurückgegeben werden'

  Scenario: Suche des Encounters anhand des Aufnahmedatums mit 'ge' und 'le' Modifikatoren
    Then Get FHIR resource at "http://fhirserver/Encounter/?date=ge2021-02-11&date=le2021-02-14" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.select((period.start.exists() and period.start > @2021-02-14) or (period.end.exists() and period.end < @2021-02-11)).allFalse()" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche des Encounters anhand des Aufnahmedatums mit dem Suchparameter end-date
    Then Get FHIR resource at "http://fhirserver/Encounter/?end-date=le2050-01-01" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(period.start <= @2050-01-01 or period.start.empty())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche des Encounters anhand des Aufnahmedatums mit dem Suchparameter date-start
    Then Get FHIR resource at "http://fhirserver/Encounter/?date-start=ge1999-01-01" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(period.end >= @1999-01-01 or period.end.empty())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Negativsuche des Encounters anhand des Suchparameters date-start
    Then Get FHIR resource at "http://fhirserver/Encounter/?date-start=ge2021-02-14" with content type "xml"
    And FHIR current response body evaluates the FHIRPath "entry.resource.where(id.replaceMatches('/_history/.+','').matches('${data.encounter-read-in-progress-id}')).count() = 0" with error message 'Der gesuchte Encounter ${data.encounter-read-in-progress-id} darf hier nicht zurückgegeben werden'

  Scenario: Negativsuche des Encounters anhand des Suchparameters end-date
    Then Get FHIR resource at "http://fhirserver/Encounter/?end-date=le2021-02-11" with content type "xml"
    And FHIR current response body evaluates the FHIRPath "entry.resource.where(id.replaceMatches('/_history/.+','').matches('${data.encounter-read-in-progress-id}')).count() = 0" with error message 'Der gesuchte Encounter ${data.encounter-read-in-progress-id} darf hier nicht zurückgegeben werden'

  Scenario: Suche des Encounters anhand des Aufnahmedatums mit mit dem Suchparameter end-date
    Then Get FHIR resource at "http://fhirserver/Encounter/?date-start=ge2021-02-11&end-date=le2021-02-14" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.select((period.start.exists() and period.start > @2021-02-14) or (period.end.exists() and period.end < @2021-02-11)).allFalse()" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche des Encounters anhand der Aufnahmenummer
    Then Get FHIR resource at "http://fhirserver/Encounter/?identifier=${data.encounter-read-in-progress-identifier-system}%7C${data.encounter-read-in-progress-identifier-value}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(identifier.where(value = '${data.encounter-read-in-progress-identifier-value}' and system = '${data.encounter-read-in-progress-identifier-system}').exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche des Encounters anhand der PatientIn
    Then Get FHIR resource at "http://fhirserver/Encounter/?patient=${data.patient-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(subject.reference.replaceMatches('/_history/.+','').matches('${data.patient-read-id}'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der PatientIn anhand der Verknüpfung mit dem Fall (Chaining)
    Then Get FHIR resource at "http://fhirserver/Encounter/?subject.family=Graf%20von%20und%20zu%20Mustermann" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.where(subject.reference.replaceMatches('/_history/.+','').matches('${data.patient-read-id}')).exists()" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche des Encounters anhand des Typs
    Then Get FHIR resource at "http://fhirserver/Encounter/?identifier=${data.encounter-read-in-progress-identifier-system}%7C" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(identifier.where(system = '${data.encounter-read-in-progress-identifier-system}').exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'
