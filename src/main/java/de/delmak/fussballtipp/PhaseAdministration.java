package de.delmak.fussballtipp;

import de.delmak.fussballtipp.persistence.Phase;
import org.apache.wicket.authroles.authorization.strategies.role.annotations.AuthorizeInstantiation;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.form.TextField;
import org.apache.wicket.markup.html.link.BookmarkablePageLink;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.markup.html.panel.FeedbackPanel;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.request.mapper.parameter.PageParameters;
import org.apache.wicket.util.string.StringValue;
import org.apache.wicket.validation.validator.StringValidator;
import org.apache.wicket.extensions.yui.calendar.DateTimeField;
import org.apache.wicket.markup.html.form.CheckBox;

@AuthorizeInstantiation("ADMIN")
public class PhaseAdministration extends BasePage
{

	private Phase phase = null;

	public final Phase getPhase()
	{
		return phase;
	}

	public final void setPhase(Phase phase)
	{
		this.phase = phase;
	}
	
	public PhaseAdministration(final PageParameters parameters)
	{
		StringValue paramMode = parameters.get("mode");
		if (paramMode.isEmpty() == false)
		{
			setMode(paramMode.toString());
		}
		
		StringValue paramPhaseId = parameters.get("phaseid");
		if (paramPhaseId.isEmpty() == false)
		{
			setPhase(Phase.getById(paramPhaseId.toInt()));
		}
		else
		if (getMode().equals(WicketApplication.MODE_INSERT))
		{
			setPhase(new Phase());
		}

		WebMarkupContainer pnlData = new WebMarkupContainer("pnlData");
		pnlData.setVisible(getMode().equals(WicketApplication.MODE_BROWSE) == true);
		add(pnlData);
		
		PageParameters pageParamsInsertData = new PageParameters();
		pageParamsInsertData.set("mode", WicketApplication.MODE_INSERT);

		pnlData.add(new BookmarkablePageLink("lnkInsertData", PhaseAdministration.class, pageParamsInsertData));
		
		ListView rptData = new ListView<Phase>("rptData", Phase.getListAll())
			{

				@Override
				protected void populateItem(ListItem item)
				{
					Phase phase = (Phase)item.getModelObject();
					
					item.add(new Label("fldPhasename", new PropertyModel(item.getModel(), "phasename")));
					item.add(new Label("fldDescription", new PropertyModel(item.getModel(), "description")));
					item.add(new Label("fldDatefrom", new PropertyModel(item.getModel(), "datefrom")));
					item.add(new Label("fldIsgroupphase", new PropertyModel(item.getModel(), "isgroupphase")));
					
					PageParameters pageParamsModifyData = new PageParameters();
					pageParamsModifyData.set("mode", WicketApplication.MODE_MODIFY);
					pageParamsModifyData.set("phaseid", phase.getPhaseId());

					item.add(new BookmarkablePageLink("lnkModifyData", PhaseAdministration.class, pageParamsModifyData));

					PageParameters pageParamsDeleteData = new PageParameters();
					pageParamsDeleteData.set("mode", WicketApplication.MODE_DELETE);
					pageParamsDeleteData.set("phaseid", phase.getPhaseId());

					item.add(new BookmarkablePageLink("lnkDeleteData", PhaseAdministration.class, pageParamsDeleteData));

					PageParameters pageParamsPhaseMatches = new PageParameters();
					pageParamsPhaseMatches.set("phaseid", phase.getPhaseId());
					
					item.add(new BookmarkablePageLink("lnkPhaseMatches", MatchAdministration.class, pageParamsPhaseMatches));

					PageParameters pageParamsPhaseBrackets = new PageParameters();
					pageParamsPhaseBrackets.set("phaseid", phase.getPhaseId());
					
					BookmarkablePageLink lnkPhaseBrackets = new BookmarkablePageLink("lnkPhaseBrackets", BracketAdministration.class, pageParamsPhaseBrackets);
					lnkPhaseBrackets.setVisible(phase.getIsgroupphase() == true);
					item.add(lnkPhaseBrackets);
				}
			};
		
		pnlData.add(rptData);
		
		Form frmData = new Form("frmData", new Model(getPhase()))
			{

				@Override
				protected void onSubmit()
				{
					if (getPhase() != null)
					{
						if (getMode().equals(WicketApplication.MODE_INSERT) == true)
						{
							Phase.insert(getPhase());
						}
						else
						if (getMode().equals(WicketApplication.MODE_MODIFY) == true)
						{
							Phase.modify(getPhase());
						}
						else
						if (getMode().equals(WicketApplication.MODE_DELETE) == true)
						{
							Phase.delete(getPhase());
						}
						
						setResponsePage(PhaseAdministration.class);
					}
				}		
			};

		frmData.setVisible(getMode().equals(WicketApplication.MODE_BROWSE) == false);
		add(frmData);
		
		String headerText = "";
		
		switch (getMode())
		{
			case WicketApplication.MODE_INSERT: headerText = "Neuanlage"; break;
			case WicketApplication.MODE_MODIFY: headerText = "Änderung"; break;
			case WicketApplication.MODE_DELETE: headerText = "Löschung"; break;
		}
		
		Label lblDataformHeader = new Label("lblDataformHeader", new Model(headerText));
		frmData.add(lblDataformHeader);
		
		TextField txtPhasename = new TextField("txtPhasename", new PropertyModel(getPhase(), "phasename"));
		txtPhasename.setRequired(true);
		txtPhasename.setEnabled(getMode().equals(WicketApplication.MODE_INSERT) == true);
		txtPhasename.add(new StringValidator(0, 20));
		frmData.add(txtPhasename);
				
		TextField txtDescription = new TextField("txtDescription", new PropertyModel(getPhase(), "description"));
		txtDescription.setRequired(true);
		txtDescription.setEnabled(getMode().equals(WicketApplication.MODE_INSERT) == true || getMode().equals(WicketApplication.MODE_MODIFY) == true);
		txtDescription.add(new StringValidator(0, 50));
		frmData.add(txtDescription);

		DateTimeField txtDatefrom = new DateTimeField("txtDatefrom", new PropertyModel(getPhase(), "datefrom"));
		txtDatefrom.setRequired(true);
		txtDatefrom.setEnabled(getMode().equals(WicketApplication.MODE_INSERT) == true || getMode().equals(WicketApplication.MODE_MODIFY) == true);
		frmData.add(txtDatefrom);

		CheckBox chkIsgroupphase = new CheckBox("chkIsgroupphase", new PropertyModel(getPhase(), "isgroupphase"));
		chkIsgroupphase.setRequired(true);
		chkIsgroupphase.setEnabled(getMode().equals(WicketApplication.MODE_INSERT) == true || getMode().equals(WicketApplication.MODE_MODIFY) == true);
		frmData.add(chkIsgroupphase);

		FeedbackPanel pnlFeedback = new FeedbackPanel("pnlFeedback");
		add(pnlFeedback);
	}
}
