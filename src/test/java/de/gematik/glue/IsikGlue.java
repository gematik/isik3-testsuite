/*
Copyright 2024 gematik GmbH

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
package de.gematik.glue;

import de.gematik.refv.commons.validation.ValidationModule;
import de.gematik.test.tiger.common.config.TigerGlobalConfiguration;
import de.gematik.test.tiger.glue.HttpGlueCode;
import de.gematik.test.tiger.glue.RBelValidatorGlue;
import de.gematik.test.tiger.glue.fhir.FhirPathValidationGlue;
import de.gematik.test.tiger.glue.fhir.StaticFhirValidationGlue;
import io.cucumber.java.After;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.restassured.http.Method;
import java.net.URI;
import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class IsikGlue {

  private final StaticFhirValidationGlue staticFhirValidationGlue = new StaticFhirValidationGlue();
  private final RBelValidatorGlue rBelValidatorGlue = new RBelValidatorGlue();
  private final FhirPathValidationGlue fhirPathValidationGlue = new FhirPathValidationGlue();
  private final HttpGlueCode httpGlueCode = new HttpGlueCode();

  @Given("Testbeschreibung: {string}")
  public void printDescription(String description) {
    String resolvedDescription = TigerGlobalConfiguration.resolvePlaceholders(description);
    log.debug(resolvedDescription);
  }

  @Given("Mit den Vorbedingungen:")
  public void configureInitialState(String initialState) {
    String resolvedInitialState = TigerGlobalConfiguration.resolvePlaceholders(initialState);
    log.debug(resolvedInitialState);
  }

  @When("Get FHIR resource at {string} with content type {string}")
  @SneakyThrows
  public void getAndValidateResource(String address, String contentType) {
    rBelValidatorGlue.tgrClearRecordedMessages();
    String resolvedAddress = TigerGlobalConfiguration.resolvePlaceholders(address);
    new HttpGlueCode().setDefaultHeader("Accept", "application/fhir+" + contentType);
    new HttpGlueCode().sendEmptyRequest(Method.GET, new URI(resolvedAddress));
    rBelValidatorGlue.findLastRequest();
    rBelValidatorGlue.currentResponseMessageAttributeMatches("$.responseCode", "200");
    rBelValidatorGlue.currentResponseMessageAttributeMatches(
        "$.header.Content-Type", "application/fhir+" + contentType + ";charset=UTF-8");
  }

  @And("CapabilityStatement contains operation {string} for resource {string}")
  public void checkCapacilityStatementContainsOperationForResourceType(
      String operation, String resourceType) {
    fhirPathValidationGlue.tgrCurrentResponseBodyEvaluatesTheFhirPath(
        String.format(
            "rest.where(mode = 'server').resource.where(type = '%s' and operation.where(name ="
                + " '%s').exists()).exists()",
            resourceType, operation),
        String.format(
            "No operation '%s' for resource '%s' found in CapabilityStatement",
            operation, resourceType));
  }

  @Then(
      "Check if current response of resource {string} is valid {supportedValidationModule} resource"
          + " and conforms to profile {string}")
  public void checkForProfileWithIdFromYaml(
      String fhirResourceName, ValidationModule validationModule, String profileUrl) {
    String fhirResourcePath = "$.body.Bundle.entry[0].resource." + fhirResourceName;
    staticFhirValidationGlue.tgrCurrentResponseAtIsValidFHIRResourceOfType(
        fhirResourcePath, validationModule, profileUrl);
  }

  @And("referenced Patient resource with id {string} conforms to ISiKPatient profile")
  public void referencedPatientResourceWithIdConformsToISIKPatientProfile(String patientId) {
    getAndValidateResource(String.format("http://fhirserver/Patient/%s", patientId), "json");
    staticFhirValidationGlue.tgrCurrentResponseBodyAtIsValidFHIRResourceOfType(
        staticFhirValidationGlue.supportedValidationModule("isik3-basismodul"),
        "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKPatient");
  }

  @And(
      "referenced Encounter resource with id {string} conforms to ISiKKontaktGesundheitseinrichtung"
          + " profile")
  public void referencedEncounterResourceWithIdConformsToISiKKontaktGesundheitseinrichtungProfile(
      String encounterId) {
    getAndValidateResource(String.format("http://fhirserver/Encounter/%s", encounterId), "json");
    staticFhirValidationGlue.tgrCurrentResponseBodyAtIsValidFHIRResourceOfType(
        staticFhirValidationGlue.supportedValidationModule("isik3-basismodul"),
        "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKKontaktGesundheitseinrichtung");
  }

  @And(
      "referenced Practitioner resource with id {string} conforms to ISiKPersonImGesundheitsberuf"
          + " profile")
  public void referencedPractitionerResourceWithIdConformsToISiKPersonImGesundheitsberufProfile(
      String practitionerId) {
    getAndValidateResource(
        String.format("http://fhirserver/Practitioner/%s", practitionerId), "json");
    staticFhirValidationGlue.tgrCurrentResponseBodyAtIsValidFHIRResourceOfType(
        staticFhirValidationGlue.supportedValidationModule("isik3-basismodul"),
        "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKPersonImGesundheitsberuf");
  }

  @And("referenced Condition resource with id {string} conforms to ISiKDiagnose profile")
  public void referencedConditionResourceWithIdConformsToISiKDiagnoseProfile(String conditionId) {
    getAndValidateResource(String.format("http://fhirserver/Condition/%s", conditionId), "json");
    staticFhirValidationGlue.tgrCurrentResponseBodyAtIsValidFHIRResourceOfType(
        staticFhirValidationGlue.supportedValidationModule("isik3-basismodul"),
        "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKDiagnose");
  }

  @And("CapabilityStatement contains interaction {string} for resource {string}")
  public void capabilitystatementContainsInteractionForResource(
      String interaction, String resourceType) {
    fhirPathValidationGlue.tgrCurrentResponseBodyEvaluatesTheFhirPath(
        String.format(
            "rest.where(mode = 'server').resource.where(type = '%s' and interaction.where(code ="
                + " '%s').exists()).exists()",
            resourceType, interaction),
        String.format(
            "No interaction '%s' for resource '%s' found in CapabilityStatement",
            interaction, resourceType));
  }

  @And("resource has ID {tigerResolvedString}")
  public void resourceHasID(String id) {
    fhirPathValidationGlue.tgrCurrentResponseBodyEvaluatesTheFhirPath(
        String.format("id.replaceMatches('/_history/.+','').matches('\\\\b%s$')", id),
        String.format("ID der Ressource entspricht nicht dem Erwartungswert (%s)", id));
  }

  @And(
      "element {tigerResolvedString} references resource with ID {tigerResolvedString} with error"
          + " message {tigerResolvedString}")
  public void elementReferencesResourceWithIDWithErrorMessage(
      String reference, String id, String errorMessage) {
    fhirPathValidationGlue.tgrCurrentResponseBodyEvaluatesTheFhirPath(
        String.format(
            "%s.reference.replaceMatches('/_history/.+','').matches('\\\\b%s$')", reference, id),
        errorMessage);
  }

  @And(
      "element {tigerResolvedString} in all bundle resources references resource with ID"
          + " {tigerResolvedString}")
  public void elementInAllBundleResourcesReferencesResourceWithID(String reference, String id) {
    fhirPathValidationGlue.tgrCurrentResponseBodyEvaluatesTheFhirPath(
        String.format(
            "entry.resource.all(%s.reference.replaceMatches('/_history/.+','').matches('\\\\b%s$'))",
            reference, id),
        "Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.");
  }

  @And(
      "response bundle contains resource with ID {tigerResolvedString} with error message"
          + " {tigerResolvedString}")
  public void responseBundleContainsResourceWithID(String id, String errorMessage) {
    fhirPathValidationGlue.tgrCurrentResponseBodyEvaluatesTheFhirPath(
        String.format(
            "entry.resource.where(id.replaceMatches('/_history/.+','').matches('\\\\b%s$')).count()"
                + " = 1",
            id),
        errorMessage);
  }

  @And(
      "bundle does not contain resource {tigerResolvedString} with ID {tigerResolvedString} with"
          + " error message {tigerResolvedString}")
  public void bundleDoesNotContainResourceWithIDWithErrorMessage(
      String resourceType, String id, String errorMessage) {
    fhirPathValidationGlue.tgrCurrentResponseBodyEvaluatesTheFhirPath(
        String.format(
            "entry.resource.ofType(%s).where(id.replaceMatches('/_history/.+','').matches('\\\\b%s$')).count()"
                + " = 0",
            resourceType, id),
        errorMessage);
  }

  @After()
  public void clearDefaultHeader() {
    httpGlueCode.clearDefaultHeaders();
  }
}
