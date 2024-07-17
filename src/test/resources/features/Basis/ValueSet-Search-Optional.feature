@basis
@optional
@ValueSet-Search
Feature: Testen von optionalen Suchparametern gegen die ValueSet Ressource (@ValueSet-Search)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall ValueSet-Read muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "xml"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "ValueSet" and searchParam.where(name = "context-type-value" and type = "composite").exists()).exists()
    """

  Scenario: Suche nach ValueSet anhand des Kontexttypen
    Then Get FHIR resource at "http://fhirserver/ValueSet/?context-type-value=focus%24http%3A%2F%2Fhl7.org%2Ffhir%2Fresource-types%7CEncounter" with content type "xml"
    Then TGR find the last request
    Then TGR current response with attribute "$.responseCode" matches "200"
    And TGR current response with attribute "$.header.Content-Type" matches "application/fhir+xml;charset=UTF-8"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.all(useContext.where(value.where(coding.where(code = 'Encounter' and system='http://hl7.org/fhir/resource-types').exists()) and code.where(code = 'focus' and system = 'http://terminology.hl7.org/CodeSystem/usage-context-type').exists()).exists())' with error message 'Das gesuchte ValueSet ${data.valueset-read-id} ist nicht im Responsebundle enthalten'