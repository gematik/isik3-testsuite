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
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der basis.yaml eingegeben worden sein.

      Legen Sie ein ValueSet in Ihrem System an, welches alle Codes aus dem CodeSystem aus Testfall CodeSystem-Read enthält:
      Url: http://example.org/fhir/ValueSet/TestValueSet
      Version: 1.0.0
      Name: TestValueSet
      Status: aktiv
      Kontext: Encounter")
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "ValueSet" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read eines ValueSet anhand der ID
    Then Get FHIR resource at "http://fhirserver/ValueSet/${data.valueset-read-id}" with content type "xml"
    Then TGR find last request to path "/ValueSet/${data.valueset-read-id}"
    Then TGR current response with attribute "$.responseCode" matches "200"
    And TGR current response with attribute "$.header.Content-Type" matches "application/fhir+xml;charset=UTF-8"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.valueset-read-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/ValueSet"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKValueSet"
    And TGR current response with attribute "$..status.value" matches "active"
    And TGR current response with attribute "$..url.value" matches "http://example.org/fhir/ValueSet/TestValueSet"
    And TGR current response with attribute "$..name.value" matches "TestValueSet"
    And TGR current response with attribute "$..ValueSet.version.value" matches "1.0.0"
    And FHIR current response body evaluates the FHIRPath "useContext.value.coding.where(code = 'Encounter').exists()" with error message 'Das ValueSet spezifiziert nicht den geforderten Kontext'
    And FHIR current response body evaluates the FHIRPath "expansion.exists()" with error message 'Das ValueSet enthält keine Expansion'
    And FHIR current response body evaluates the FHIRPath "expansion.contains.where(code = 'test' and display = 'Test' and system = 'http://example.org/fhir/CodeSystem/TestKatalog').exists()" with error message 'Das ValueSet enthält nicht die erforderlichen Codes'
