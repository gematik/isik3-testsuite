@terminplanung
@mandatory
@HealthcareService-Read
Feature: Lesen der Ressource HealthcareService (@HealthcareService-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in terminplanung.yaml eingegeben worden sein.

      Legen Sie den folgenden Termin in Ihrem System an:
      Status: aktiv
      Behandlungstyp: Neurologie
      Fachrichtung: Neurologie
      Name: Allgemeine Beratungsstelle der Fachabteilung Neurologie
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "HealthcareService" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read eines medizinischen Behandlungseinheit anhand der ID
    Then Get FHIR resource at "http://fhirserver/HealthcareService/${data.healthcareservice-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.healthcareservice-read-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/HealthcareService"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKMedizinischeBehandlungseinheit"
    And TGR current response with attribute "$..active.value" matches "true"
    And FHIR current response body evaluates the FHIRPath "type.where(coding.where(code = '177' and system = 'http://terminology.hl7.org/CodeSystem/service-type').exists()).exists()" with error message 'Der Typ entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "specialty.where(coding.where(code = '142' and system = 'urn:oid:1.2.276.0.76.5.114').exists()).exists()" with error message 'Die Fachrichtung entspricht nicht dem Erwartungswert'
    And TGR current response with attribute "$..name.value" matches "Allgemeine Beratungsstelle der Fachabteilung Neurologie"
    