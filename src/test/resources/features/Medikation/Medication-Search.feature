@medikation
@mandatory
@Medication-Search
Feature: Testen von Suchparametern gegen die Medication Ressource (@Medication-Search)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Medication-Read und Medication-Read-Extended muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Medication" and interaction.where(code = "search-type").exists()).exists()
    """

  Scenario Outline: Validierung des CapabilityStatements von <searchParamValue>
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Medication" and searchParam.where(name = "<searchParamValue>" and type = "<searchParamType>").exists()).exists()
    """

    Examples:
      | searchParamValue | searchParamType |
      | _id              | token           |
      | code             | token           |
      | form             | token           |
      | ingredient       | reference       |
      | ingredient-code  | token           |
      | lot-number       | token           |
      | status           | token           |

  Scenario: Suche nach des Medikaments anhand der ID
    Then Get FHIR resource at "http://fhirserver/Medication/?_id=${data.medication-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.where(id.replaceMatches("/_history/.+","").matches("${data.medication-read-id}")).count() = 1' with error message 'Das gesuchte Medikament ${data.medication-read-id} ist nicht im Responsebundle enthalten'
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "Medication" is valid ISIK3 and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikament"

  Scenario: Suche nach des Medikaments anhand des Codes
    Then Get FHIR resource at "http://fhirserver/Medication/?code=http://fhir.de/CodeSystem/bfarm/atc%7CV03AB23" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all((code.coding.where(code = 'V03AB23' and system = 'http://fhir.de/CodeSystem/bfarm/atc').exists()))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche des Medikaments anhand des Freitext Codes
    Then Get FHIR resource at "http://fhirserver/Medication/?code:text=Infusion" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(code.text.contains('Infusion'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche des Medikaments anhand der Abgabeform
    Then Get FHIR resource at "http://fhirserver/Medication/?form=11210000" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(form.coding.where(code = '11210000').exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche des Medikaments anhand des referenzierten Bestandteils der Rezeptur
    Then Get FHIR resource at "http://fhirserver/Medication/?ingredient=Medication/${data.medication-read-referenced-ingredient}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(ingredient.item.reference.replaceMatches('/_history/.+','').matches('${data.medication-read-referenced-ingredient}'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche des Medikaments anhand des Rezeptur Codes
    Then Get FHIR resource at "http://fhirserver/Medication/?ingredient.code=L01DB01" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.where(ingredient.item.reference.replaceMatches('/_history/.+','').matches('${data.medication-read-referenced-ingredient}')).exists()" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche des Medikaments anhand des Rezeptur Codes
    Then Get FHIR resource at "http://fhirserver/Medication/?ingredient-code=L01DB01" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.where(id.replaceMatches('/_history/.+','').matches('${data.medication-read-extended-id}')).count()=1" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario Outline: Suche des Medikaments anhand des <title>
    Then Get FHIR resource at "http://fhirserver/Medication/?<searchParameter>=<searchValue>" with content type "<contentType>"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(<testParameter> = '<searchValue>')" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

    Examples:
      | title          | contentType | searchParameter | testParameter   | searchValue |
      | Rezeptur Codes | xml         | lot-number      | batch.lotNumber | 123         |
      | Status         | json        | status          | status          | active      |