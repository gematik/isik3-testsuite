@basis
@dokumentenaustausch
@terminplanung
@mandatory
@Binary-Read
Feature: Lesen der Ressource Binary (@Binary-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der shared.yaml eingegeben worden sein.

      Legen Sie die folgenden Binärdaten in Ihrem System an:
      Mime-Type: text/plain
      Textuelle Daten (UTF-8, LF (Unix)): Test
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "Binary" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read von Binärdaten anhand der ID
    Then Get FHIR resource at "http://fhirserver/Binary/${data.binary-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.binary-read-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/Binary"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKBinary"
    And TGR current response with attribute "$..contentType.value" matches "text/plain"
    And TGR current response with attribute "$..data.value" matches "VGVzdA=="
