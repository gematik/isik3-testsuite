@terminplanung
@mandatory
@HealthcareService-Search
Feature: Testen von Suchparametern gegen die HealthcareService Ressource (@HealthcareService-Search)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall HealthcareService-Read muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "xml"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "HealthcareService" and interaction.where(code = "search-type").exists()).exists()
    """

  Scenario Outline: Validierung des CapabilityStatements für <searchParamValue>
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "HealthcareService" and searchParam.where(name = "<searchParamValue>" and type = "<searchParamType>").exists()).exists()
    """

    Examples:
      | searchParamValue | searchParamType |
      | _id              | token           |
      | active           | token           |
      | service-type     | token           |
      | specialty        | token           |
      | name             | string          |

  Scenario: Suche nach dem HealthcareService anhand der ID
    Then Get FHIR resource at "http://fhirserver/HealthcareService/?_id=${data.healthcareservice-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.where(id.replaceMatches("/_history/.+","").matches("${data.healthcareservice-read-id}")).count()=1' with error message 'Der gesuchte HealthcareService ${data.healthcareservice-read-id} ist nicht im Responsebundle enthalten'
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "HealthcareService" is valid ISIK3 and conforms to profile "https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKMedizinischeBehandlungseinheit"

  Scenario: Suche nach der Nachricht anhand des Status
    Then Get FHIR resource at "http://fhirserver/HealthcareService/?active=true" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(active = 'true')" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario Outline: Suche nach der Nachricht anhand <title>
    Then Get FHIR resource at "http://fhirserver/HealthcareService/?<searchParameter>=<searchValue>" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(<coding>.coding.where(code='<searchValue>').exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

    Examples:
      | title               | searchParameter | coding    | searchValue |
      | des Behandlungstyps | service-type    | type      | 177         |
      | der Fachrichtung    | specialty       | specialty | 142         |

  Scenario: Suche nach der Nachricht anhand des Namens
    Then Get FHIR resource at "http://fhirserver/HealthcareService/?name=Allgemeine%20Beratungsstelle%20der%20Fachabteilung%20Neurologie" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(name.contains('Allgemeine Beratungsstelle der Fachabteilung Neurologie'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'
