@terminplanung
@optional
@Encounter-Search-Appointment
Feature: Testen von Suchparametern gegen Encounter-Read-Appointment (@Encounter-Search-Appointment)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      -  Der Testfall Encounter-Read-Appointment muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario Outline: Validierung des CapabilityStatements von <searchParamValue>
    When Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Encounter" and searchParam.where(name = "<searchParamValue>" and type = "<searchParamType>").exists()).exists()
    """

    Examples:
      | searchParamValue | searchParamType |
      | appointment      | reference       |

  Scenario: Suche des Encounters anhand der Patienten-Id
    Then Get FHIR resource at "http://fhirserver/Encounter/?appointment=${data.appointment-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And response bundle contains resource with ID "${data.encounter-read-appointment-id}" with error message "Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien."