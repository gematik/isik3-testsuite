@basis
@mandatory
@ValueSet-Read
Feature: Lesen der Ressource ValueSet (ValueSet-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der Konfigurationsvariable 'valueset-read-id' hinterlegt sein.

      Legen Sie ein ValueSet in Ihrem System an, welches Codes 'sat' und 'sun' aus dem FHIR CodeSystem http://hl7.org/fhir/days-of-week enthält
      Version: 1.0.0
      Name: TestValueSet
      Status: aktiv
      Kontext: Encounter
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "ValueSet"

  Scenario: Read eines ValueSet anhand der ID
    Then Get FHIR resource at "http://fhirserver/ValueSet/${data.valueset-read-id}" with content type "xml"
    Then TGR find last request to path "/ValueSet/${data.valueset-read-id}"
    Then TGR current response with attribute "$.responseCode" matches "200"
    And TGR current response with attribute "$.header.Content-Type" matches "application/fhir+xml;charset=UTF-8"
    And resource has ID "${data.valueset-read-id}"
    And FHIR current response body is a valid isik3-basismodul resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKValueSet"
    And TGR current response with attribute "$..status.value" matches "active"
    And TGR current response with attribute "$..url.value" matches "http://example.org/fhir/ValueSet/TestValueSet"
    And TGR current response with attribute "$..name.value" matches "TestValueSet"
    And TGR current response with attribute "$..ValueSet.version.value" matches "1.0.0"
    And FHIR current response body evaluates the FHIRPath "useContext.value.coding.where(code = 'Encounter').exists()" with error message 'Das ValueSet spezifiziert nicht den geforderten Kontext'
    And FHIR current response body evaluates the FHIRPath "expansion.exists()" with error message 'Das ValueSet enthält keine Expansion'
    And FHIR current response body evaluates the FHIRPath "expansion.contains.where(code = 'sun' and display = 'Sunday' and system = 'http://hl7.org/fhir/days-of-week').exists()" with error message 'Das ValueSet enthält nicht die erforderlichen Codes'
