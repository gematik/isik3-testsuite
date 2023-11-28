@basis
@mandatory
@Coverage-Read-Statutory
Feature: Lesen der Ressource Coverage (@Coverage-Read-Statutory)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der basis.yaml eingegeben worden sein.

      Testdatensatz (Name: Wert)
      Erfassen Sie folgendes Versicherungsverhältnis:
      Status: aktiv/gültig
      Versicherungsart: gesetzlich
      Versicherten-ID: X485231029
      Versicherung: AOK Baden-Württemberg
      IK-Nummer: 108018007
      Begünstigter: Beliebig (Bitte ID in der basis.yaml eingeben)
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "Coverage" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read einer Coverage-Ressource anhand ihrer ID
    Then Get FHIR resource at "http://fhirserver/Coverage/${data.coverage-read-statutory-id}" with content type "xml"
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/Coverage"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKVersicherungsverhaeltnisGesetzlich"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.coverage-read-statutory-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body evaluates the FHIRPath "identifier.where(type.coding.system='http://fhir.de/CodeSystem/identifier-type-de-basis' and type.coding.code='GKV' and system='http://fhir.de/sid/gkv/kvid-10' and value = 'X485231029').exists()" with error message 'Der Identifier entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "type.coding.where(system='http://fhir.de/CodeSystem/versicherungsart-de-basis' and code = 'GKV').exists()" with error message 'Der Typ entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath 'beneficiary.reference.replaceMatches("/_history/.+","").matches("${data.patient-read-id}")' with error message 'Referenzierter Patient entspricht nicht dem Erwartungswert'

    And TGR current response with attribute "$..status.value" matches "active"
    And FHIR current response body evaluates the FHIRPath "payor.identifier.type.coding.where(system = 'http://terminology.hl7.org/CodeSystem/v2-0203' and code = 'XX').exists()" with error message 'Der Typ des Identifiers des Versicherers entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "payor.identifier.where(system = 'http://fhir.de/sid/arge-ik/iknr' and value = '108018007').exists()" with error message 'Der Identifier des Versicherers entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "payor.display = 'AOK Baden-Württemberg'" with error message 'Der Display Wert des Versicherers entspricht nicht dem Erwartungswert'
