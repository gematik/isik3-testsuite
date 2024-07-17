@terminplanung
@mandatory
@Appointment-Book-By-Schedule
Feature: Buchung eines Termins anhand der Kalender-Referenz (@Appointment-Book-By-Schedule)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS Buchung von Terminen anhand der Kalender-Referenz unterstützen."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Schedule-Read muss zuvor erfolgreich ausgeführt worden sein.
      - Ein freier Terminblock mit Startzeit 1.9.2024 09:00 und Endzeit 1.9.2024 20:00 muss zuvor manuell im Kalender aus dem Testfall Schedule-Read angelegt worden sein
      - Behandlungstyp: der Behandlungstyp aus dem Testfall Schedule-Read
    """

  Scenario: Buchung eines Termins anhand der Kalender-Referenz
    Given TGR set default header "Content-Type" to "application/fhir+json"
    And TGR send POST request to "http://fhirserver/Appointment/$book" with body "!{file('src/test/resources/features/Terminplanung/fixtures/Appointment-Appointment-Book-By-Schedule-Parameters-Fixture.json')}"
    Then TGR find the last request
    And TGR current response with attribute "$.responseCode" matches "20\d"
    #  Asserts for the case if the response is an Appointment
    And FHIR current response body evaluates the FHIRPath '($this is Appointment) or ($this is Parameters)' with error message 'Rückgabe enthält weder eine Appointment noch eine OperationOutcome-Ressource noch eine Parameters-Ressource'
    And FHIR current response body evaluates the FHIRPath '($this is Appointment) implies id.exists()' with error message 'Rückgabevariante Appointment: Dem Termin wurde keine ID zugewiesen'
    And FHIR current response body evaluates the FHIRPath "($this is Appointment) implies status.toString().matches('^booked|pending$')" with error message 'Rückgabevariante Appointment: Dem Termin wurde keine ID zugewiesen'
    And FHIR current response body evaluates the FHIRPath "($this is Appointment) implies slot.exists()" with error message 'Rückgabevariante Appointment: Kein Slot zugeordnet'
    #  Asserts for the case if the response is a Parameters-Ressource
    And FHIR current response body evaluates the FHIRPath "($this is Parameters) implies parameter.where(name = 'return' and resource is Appointment).resource.id.exists()" with error message 'Rückgabevariante Parameters: Dem Termin wurde keine ID zugewiesen'
    And FHIR current response body evaluates the FHIRPath "($this is Parameters) implies parameter.where(name = 'return' and resource is Appointment).resource.status.toString().matches('^booked|pending$')" with error message 'Rückgabevariante Parameters: Status des Termins ist weder booked noch pending'
    And FHIR current response body evaluates the FHIRPath "($this is Parameters) implies parameter.where(name = 'return' and resource is Appointment).resource.slot.exists()" with error message 'Rückgabevariante Parameters: Kein Slot zugeordnet'