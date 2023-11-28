@basis
@mandatory
@CodeSystem-Read
Feature: Lesen der Ressource CodeSystem (@CodeSystem-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss im basis.yaml eingegeben worden sein.

      Legen Sie das folgende CodeSystem in Ihrem System an:
      Url: http://example.org/fhir/CodeSystem/TestKatalog
      Version: 1.0.0
      Name: testkatalog
      Status: aktiv
      Inhalt: Vollständig
      Enthaltener Code (Code, Display-Wert, Definition): test, Test, Dies ist ein Test-Code")
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "CodeSystem" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read eines CodeSystem anhand der ID
    Then Get FHIR resource at "http://fhirserver/CodeSystem/${data.codesystem-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.codesystem-read-id}")' with error message "ID der Ressource entspricht nicht der angeforderten ID"
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/CodeSystem"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKCodeSystem"

    And TGR current response with attribute "$..status.value" matches "active"
    And TGR current response with attribute "$..content.value" matches "complete"
    And TGR current response with attribute "$..url.value" matches "http://example.org/fhir/CodeSystem/TestKatalog"
    And TGR current response with attribute "$..name.value" matches "testkatalog"
    And TGR current response with attribute "$..version.value" matches "1.0.0"
    And TGR current response contains node "$..concept"
    And FHIR current response body evaluates the FHIRPath 'concept.where(code = "test" and display = "Test" and definition = "Dies ist ein Test-Code").exists()' with error message 'Das CodeSystem enthält keine Codes'
