@dokumentenaustausch
@mandatory
@DocumentReference-Search-Server
Feature: Testen von Suchparametern gegen die DocumentReference Ressource (@DocumentReference-Search-Server)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall DocumentReference-Read muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "DocumentReference" and interaction.where(code = "search-type").exists()).exists()
    """

  Scenario Outline: Validierung des CapabilityStatements für <searchParamValue>
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "DocumentReference" and searchParam.where(name = "<searchParamValue>" and type = "<searchParamType>").exists()).exists()
    """

    Examples:
      | searchParamValue | searchParamType |
      | _id              | token           |
      | status           | token           |
      | patient          | reference       |
      | type             | token           |
      | category         | token           |
      | creation         | date            |
      | encounter        | reference       |

  Scenario: Suche nach dem Termin anhand der ID
    Then Get FHIR resource at "http://fhirserver/DocumentReference/?_id=${data.documentreference-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.where(id.replaceMatches("/_history/.+","").matches("${data.documentreference-read-id}")).count() = 1' with error message 'Die gesuchte DocumentReference ${data.documentreference-read-id} ist nicht im Responsebundle enthalten'
    And FHIR current response body is a valid CORE resource and conforms to profile "https://gematik.de/fhir/isik/v3/Dokumentenaustausch/StructureDefinition/ISiKDokumentenSuchergebnisse"
    And Check if current response of resource "DocumentReference" is valid ISIK3 and conforms to profile "https://gematik.de/fhir/isik/v3/Dokumentenaustausch/StructureDefinition/ISiKDokumentenMetadaten"

  Scenario: Suche nach Dokumentenmetadaten anhand des Status
    Then Get FHIR resource at "http://fhirserver/DocumentReference/?status=current" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(status = 'current')" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche nach Dokumentenmetadaten anhand der PatientIn
    Then Get FHIR resource at "http://fhirserver/DocumentReference/?patient=Patient/${data.patient-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(subject.reference.replaceMatches('/_history/.+','').matches('${data.patient-read-id}'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario Outline: Suche nach Dokumentenmetadaten anhand <title>
    Then Get FHIR resource at "http://fhirserver/DocumentReference/?<searchParameter>=<searchValue>" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.where(id.replaceMatches('/_history/.+','').matches('${data.documentreference-read-id}')).count() = 1" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

    Examples:
      | title                   | searchParameter              | searchValue                           |
      | der Patientennummer     | patient.identifier           | ${data.patient-read-identifier-value} |
      | des Account Identifiers | encounter.account.identifier | ${data.account-read-identifier-value} |

  Scenario: Suche nach Dokumentenmetadaten anhand des Typs
    Then Get FHIR resource at "http://fhirserver/DocumentReference/?type=http://dvmd.de/fhir/CodeSystem/kdl%7CPT130102" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(type.coding.where(code='PT130102' and system = 'http://dvmd.de/fhir/CodeSystem/kdl').exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche nach Dokumentenmetadaten anhand der Kategorie
    Then Get FHIR resource at "http://fhirserver/DocumentReference/?category=http://ihe-d.de/CodeSystems/IHEXDSclassCode%7CBEF" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(category.coding.where(code = 'BEF' and system = 'http://ihe-d.de/CodeSystems/IHEXDSclassCode').exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche nach Dokumentenmetadaten anhand des Erstellungsdatums
    Then Get FHIR resource at "http://fhirserver/DocumentReference/?creation=2020-12-31" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(content.attachment.where(creation.toString().contains('2020-12-31')).exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche nach Dokumentenmetadaten anhand des Kontakts
    Then Get FHIR resource at "http://fhirserver/DocumentReference/?encounter=Encounter/${data.encounter-read-finished-id}" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(context.encounter.where(reference.replaceMatches('/_history/.+','').matches('${data.encounter-read-finished-id}')).exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'
